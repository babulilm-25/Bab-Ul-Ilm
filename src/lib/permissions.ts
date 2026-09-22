export type Permission =
  | 'dashboard.view'
  | 'users.view' | 'users.create' | 'users.edit' | 'users.disable'
  | 'roles.view' | 'roles.create' | 'roles.edit' | 'roles.delete'
  | 'students.view' | 'students.create' | 'students.edit' | 'students.archive' | 'students.delete' | 'students.export'
  | 'teachers.view' | 'teachers.create' | 'teachers.edit' | 'teachers.delete'
  | 'attendance.view' | 'attendance.create' | 'attendance.edit' | 'attendance.delete'
  | 'fees.view' | 'fees.create' | 'fees.edit' | 'fees.delete' | 'fees.refund'
  | 'finance.view' | 'finance.create' | 'finance.edit' | 'finance.delete' | 'finance.export'
  | 'settings.view' | 'settings.edit' | 'reports.view' | 'reports.create' | 'reports.export'

export const hasPermission = (permissions:Set<string>, required:Permission) =>
  permissions.has('*') || permissions.has(required)
