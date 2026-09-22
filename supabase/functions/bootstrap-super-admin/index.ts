import { createClient } from "npm:@supabase/supabase-js@2"

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-bootstrap-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } })

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors })
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405)

  const expected = Deno.env.get("BABULILM_BOOTSTRAP_SECRET")
  const supplied = req.headers.get("x-bootstrap-secret")
  if (!expected || !supplied || supplied !== expected) return json({ error: "Unauthorized" }, 401)

  const url = Deno.env.get("SUPABASE_URL")
  const secretKeys = Deno.env.get("SUPABASE_SECRET_KEYS")
  if (!url || !secretKeys) return json({ error: "Server configuration unavailable" }, 503)

  const secretKey = JSON.parse(secretKeys).default
  if (!secretKey) return json({ error: "Server secret key unavailable" }, 503)

  const admin = createClient(url, secretKey, { auth: { autoRefreshToken: false, persistSession: false } })

  const claim = await admin.rpc("bootstrap_claim")
  if (claim.error) return json({ error: "Bootstrap state could not be checked" }, 500)
  if (!claim.data?.allowed) {
    return json({ error: claim.data?.reason === "completed" ? "Bootstrap already completed" : "Bootstrap locked" }, 409)
  }

  let body: { email?: string; password?: string } = {}
  try { body = await req.json() } catch { return json({ error: "Invalid JSON body" }, 400) }

  const email = String(body.email ?? "").trim().toLowerCase()
  const password = String(body.password ?? "")
  if (email !== "admin@babulilm.local" || password.length < 12) {
    return json({ error: "Invalid bootstrap credentials" }, 400)
  }

  const created = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { display_name: "Super Admin" },
  })
  if (created.error || !created.data.user) {
    return json({ error: created.error?.message ?? "Could not create bootstrap user" }, 409)
  }

  const finalized = await admin.rpc("bootstrap_finalize", {
    target_user_id: created.data.user.id,
    target_email: email,
  })
  if (finalized.error) {
    await admin.auth.admin.deleteUser(created.data.user.id)
    return json({ error: "Bootstrap finalization failed" }, 500)
  }

  return json({ ok: true, user_id: created.data.user.id, must_change_password: true })
})
