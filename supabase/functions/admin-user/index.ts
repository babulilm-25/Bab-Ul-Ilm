import { createClient } from "npm:@supabase/supabase-js@2"

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } })

type Body = {
  action?: "create" | "disable" | "enable" | "reset_password" | "delete"
  user_id?: string
  email?: string
  password?: string
  display_name?: string
  role_id?: string
  branch_id?: string
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors })
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405)

  const url = Deno.env.get("SUPABASE_URL")
  const secretKeys = Deno.env.get("SUPABASE_SECRET_KEYS")
  if (!url || !secretKeys) return json({ error: "Server configuration unavailable" }, 503)
  let secretKey = ""
  try { secretKey = JSON.parse(secretKeys).default ?? "" } catch { return json({ error: "Server secret key unavailable" }, 503) }
  if (!secretKey) return json({ error: "Server secret key unavailable" }, 503)

  const authHeader = req.headers.get("authorization")
  const token = authHeader?.replace(/^Bearer\s+/i, "")
  if (!token) return json({ error: "Unauthorized" }, 401)

  const admin = createClient(url, secretKey, { auth: { autoRefreshToken: false, persistSession: false } })
  const { data: callerData, error: callerError } = await admin.auth.getUser(token)
  if (callerError || !callerData.user) return json({ error: "Unauthorized" }, 401)
  const callerId = callerData.user.id

  const { data: callerProfile, error: profileError } = await admin
    .from("profiles").select("id,institution_id,disabled_at").eq("id", callerId).single()
  if (profileError || !callerProfile?.institution_id || callerProfile.disabled_at) return json({ error: "Forbidden" }, 403)

  const { data: callerRoles, error: rolesError } = await admin
    .from("user_roles").select("roles!inner(slug,institution_id)").eq("user_id", callerId)
  if (rolesError) return json({ error: "Authorization check failed" }, 500)
  const roleRows = (callerRoles ?? []) as Array<{ roles: { slug: string; institution_id: string | null } }>
  const isSuper = roleRows.some(r => r.roles.slug === "super-admin")
  const hasUsersCreate = isSuper || (await hasPermission(admin, callerId, "users.create"))
  const hasUsersEdit = isSuper || (await hasPermission(admin, callerId, "users.edit"))
  if (!hasUsersCreate && !hasUsersEdit) return json({ error: "Forbidden" }, 403)

  let body: Body = {}
  try { body = await req.json() } catch { return json({ error: "Invalid JSON body" }, 400) }
  const action = body.action

  if (action === "create") {
    if (!hasUsersCreate) return json({ error: "Missing users.create permission" }, 403)
    const email = String(body.email ?? "").trim().toLowerCase()
    const password = String(body.password ?? "")
    const displayName = String(body.display_name ?? "").trim()
    if (!email || !password || password.length < 12) return json({ error: "Email and a 12+ character password are required" }, 400)

    if (body.role_id) {
      const { data: role } = await admin.from("roles").select("id,institution_id,is_system,slug").eq("id", body.role_id).single()
      if (!role || (role.institution_id !== null && role.institution_id !== callerProfile.institution_id) || (role.slug === "super-admin" && !isSuper)) {
        return json({ error: "Invalid role for this institution" }, 400)
      }
    }
    if (body.branch_id) {
      const { data: branch } = await admin.from("branches").select("id,institution_id").eq("id", body.branch_id).single()
      if (!branch || branch.institution_id !== callerProfile.institution_id) return json({ error: "Invalid branch" }, 400)
    }

    const created = await admin.auth.admin.createUser({ email, password, email_confirm: true, user_metadata: { display_name: displayName || null } })
    if (created.error || !created.data.user) return json({ error: created.error?.message ?? "Could not create user" }, 409)
    const uid = created.data.user.id

    const { error: pError } = await admin.from("profiles").update({ institution_id: callerProfile.institution_id, display_name: displayName || null, must_change_password: true }).eq("id", uid)
    if (pError) { await admin.auth.admin.deleteUser(uid); return json({ error: "Could not initialize profile" }, 500) }

    if (body.role_id) {
      const { error } = await admin.from("user_roles").insert({ user_id: uid, role_id: body.role_id })
      if (error) { await admin.auth.admin.deleteUser(uid); return json({ error: "Could not assign role" }, 500) }
    }
    if (body.branch_id) {
      const { error } = await admin.from("user_branches").insert({ user_id: uid, branch_id: body.branch_id })
      if (error) { await admin.auth.admin.deleteUser(uid); return json({ error: "Could not assign branch" }, 500) }
    }
    await admin.from("audit_logs").insert({ institution_id: callerProfile.institution_id, actor_user_id: callerId, action: "user.created", entity_type: "profile", entity_id: uid, metadata: { email, role_id: body.role_id ?? null, branch_id: body.branch_id ?? null } })
    return json({ ok: true, user_id: uid, must_change_password: true })
  }

  if (!body.user_id) return json({ error: "user_id is required" }, 400)
  if (body.user_id === callerId && (action === "disable" || action === "reset_password")) return json({ error: "Use your own security settings for this account" }, 400)

  const { data: targetProfile } = await admin.from("profiles").select("id,institution_id,disabled_at").eq("id", body.user_id).single()
  if (!targetProfile || targetProfile.institution_id !== callerProfile.institution_id) return json({ error: "User outside institution" }, 404)

  const { data: targetRoles } = await admin.from("user_roles").select("roles!inner(slug)").eq("user_id", body.user_id)
  const targetIsSuper = ((targetRoles ?? []) as Array<{roles:{slug:string}}>).some(r => r.roles.slug === "super-admin")
  if (targetIsSuper && !isSuper) return json({ error: "Only Super Admin can manage a Super Admin account" }, 403)

  if (action === "disable") {
    const { error: authError } = await admin.auth.admin.updateUserById(body.user_id, { ban_duration: "876000h" })
    if (authError) return json({ error: authError.message }, 400)
    await admin.from("profiles").update({ disabled_at: new Date().toISOString() }).eq("id", body.user_id)
    await admin.from("audit_logs").insert({ institution_id: callerProfile.institution_id, actor_user_id: callerId, action: "user.disabled", entity_type: "profile", entity_id: body.user_id })
    return json({ ok: true })
  }

  if (action === "enable") {
    const { error: authError } = await admin.auth.admin.updateUserById(body.user_id, { ban_duration: "none" })
    if (authError) return json({ error: authError.message }, 400)
    await admin.from("profiles").update({ disabled_at: null }).eq("id", body.user_id)
    await admin.from("audit_logs").insert({ institution_id: callerProfile.institution_id, actor_user_id: callerId, action: "user.enabled", entity_type: "profile", entity_id: body.user_id })
    return json({ ok: true })
  }

  if (action === "delete") {
    if (!hasUsersEdit) return json({ error: "Missing users.edit permission" }, 403)
    if (targetIsSuper && !isSuper) return json({ error: "Only Super Admin can delete a Super Admin account" }, 403)
    await admin.from("audit_logs").insert({ institution_id: callerProfile.institution_id, actor_user_id: callerId, action: "user.deleted", entity_type: "profile", entity_id: body.user_id })
    const { error: authError } = await admin.auth.admin.deleteUser(body.user_id)
    if (authError) return json({ error: authError.message }, 400)
    return json({ ok: true })
  }

  if (action === "reset_password") {
    if (!hasUsersEdit) return json({ error: "Missing users.edit permission" }, 403)
    const password = String(body.password ?? "")
    if (password.length < 12) return json({ error: "Password must be at least 12 characters" }, 400)
    const { error: authError } = await admin.auth.admin.updateUserById(body.user_id, { password })
    if (authError) return json({ error: authError.message }, 400)
    await admin.from("profiles").update({ must_change_password: true }).eq("id", body.user_id)
    await admin.from("audit_logs").insert({ institution_id: callerProfile.institution_id, actor_user_id: callerId, action: "user.password_reset", entity_type: "profile", entity_id: body.user_id })
    return json({ ok: true, must_change_password: true })
  }

  return json({ error: "Unsupported action" }, 400)
})

async function hasPermission(client: ReturnType<typeof createClient>, userId: string, key: string) {
  const { data } = await client
    .from("user_roles")
    .select("roles!inner(role_permissions!inner(permissions!inner(key)))")
    .eq("user_id", userId)
  const rows = (data ?? []) as Array<{ roles: { role_permissions: Array<{ permissions: { key: string } }> } }>
  return rows.some(r => r.roles.role_permissions.some(rp => rp.permissions.key === key))
}
