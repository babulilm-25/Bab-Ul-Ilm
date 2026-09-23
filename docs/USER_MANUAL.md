# Bab UL Ilm — User Manual

## 1. About the application
Bab UL Ilm is the Madarsa management platform for Madarsa Ahle Sunnat Bab UL Ilm Raza E Mustafa. It provides administration, students, academics, staff, attendance, examinations, fees, library, inventory, reports, communication and portal functions.

## 2. First login
1. Open the Bab UL Ilm Android app.
2. Enter the email and password provided by the Super Admin.
3. On a newly created account, the app requires a password change before the administration console opens.
4. Set a new password of at least 12 characters and confirm it.
5. After successful change, the Dashboard opens.
6. Never share your password. Use a unique strong password. Supabase recommends long, non-reused passwords and supports stronger password controls. 

## 3. Main navigation
- Dashboard
- Users
- Roles & Permissions
- Branches
- Security
- Students
- Academics
- Teachers / Staff
- Timetable & Attendance
- Exams & Results
- Fees & Finance
- Library & Inventory
- Reports & Certificates
- Communication & Portal

On mobile, use the bottom navigation for quick access and More for the remaining modules. Use the menu button to open the full sidebar.

## 4. Dashboard
Shows institution status, branches, roles, recent audit activity and feature controls.
Online payments and provider-dependent SMS are intentionally OFF until integrations are configured.

## 5. Users
Super Admin:
1. Open Users.
2. Tap New user.
3. Enter name, email and temporary password (12+ characters).
4. Select a role and branch if required.
5. Create the user.
6. Give the user the temporary credentials securely.
7. The user signs in and must change the temporary password.
8. Use Disable/Enable to control account access.

## 6. Roles & Permissions
1. Open Roles & Permissions.
2. Review system and custom roles.
3. Create a custom role with a unique name and slug.
4. Assign roles to users from the user-management flow.
5. Use least privilege: give each staff member only the access required for their work.

## 7. Branches
1. Open Branches.
2. Tap New branch.
3. Enter branch name and code.
4. Save.
5. Branch access is enforced by database authorization.

## 8. Security
### MFA
1. Open Security.
2. Select Add authenticator.
3. Scan the displayed QR code in an authenticator app.
4. Enter the 6-digit code.
5. Tap Verify & enable.
6. Remove a factor only when you are sure it is no longer needed.

## 9. Students & Admissions
1. Open Students.
2. Use the Students tab to add and manage student records.
3. Enter admission and personal/guardian information.
4. Use Admissions to record admission workflow.
5. Search/filter the displayed records and refresh after major changes.
6. Keep student identity and guardian information accurate because other modules reference the student record.

## 10. Academics
1. Open Academics.
2. Create academic classes.
3. Create sections.
4. Create subjects.
5. Link subjects to classes.
6. Add curriculum units where needed.
7. Complete academic setup before timetable and examination work.

## 11. Teachers / Staff
1. Open Teachers / Staff.
2. Add staff records.
3. Record staff information.
4. Use Assignments to link teachers with subjects and classes.
5. Keep active/inactive staff information current.
6. Staff document storage is part of the data model; file-upload integration is not enabled in the current build.

## 12. Timetable & Attendance
### Timetable
1. Open Timetable & Attendance.
2. Choose class, section, subject and teacher.
3. Select weekday and period.
4. Add room if required.
5. Save the timetable entry.

### Attendance
1. Open the Attendance tab.
2. Select class, date and period.
3. Create or reuse the attendance session.
4. Review the active student roster.
5. Mark each student Present, Absent, Late or Leave.
6. Save attendance.
7. Close the session when the period is finalized.
8. Previous sessions appear in history.

## 13. Exams & Results
### Exams
1. Create an exam.
2. Add exam subjects/papers.
3. Select the relevant class/subject.
### Results
1. Open Results.
2. Select the exam/paper and student.
3. Enter marks.
4. Review the automatically calculated grade where configured.
5. Save the result.
### Promotion
1. Open Promotion.
2. Select students and the promotion action.
3. Review carefully before saving because promotion changes academic progression records.

## 14. Fees & Finance
### Fee Structure
1. Create fee structures.
2. Set the amount and applicable information.
### Dues
1. Assign fees to students.
2. Review due/partial/paid status.
### Receipts
1. Record received payments.
2. The system recalculates assignment status from payment totals.
### Expenses
1. Record institutional expenses.
2. Select the appropriate finance category.
3. Keep references/notes for audit purposes.

Online payment gateway processing is intentionally disabled in the current build. Manual payment records can be entered.

## 15. Library & Inventory
### Books
1. Add books with title, author, ISBN and copy information.
2. Keep available copies accurate.
### Issues
1. Select exactly one borrower: student or staff.
2. Select the book.
3. Enter issue and due dates.
4. Save.
5. Use Return when the book comes back.
6. Use Lost when a book is reported lost.
### Inventory
1. Add inventory items.
2. Record stock-in, stock-out or adjustment transactions.
3. Review stock history.
4. Stock quantity is updated by database automation.

## 16. Reports & Certificates
### Templates
1. Create a report template.
2. Select progress, attendance, fee, staff or custom type.
### Certificates
1. Select a student.
2. Select certificate type.
3. Enter title, certificate number and remarks.
4. Issue the certificate.
5. Use Print to generate a print-ready official document.
### Documents
1. Select student or Institution document.
2. Choose document type.
3. Enter title and document number.
4. Record it.
5. Use Print for the print-ready document.

The current build uses browser/Android print output; direct PDF/file-storage upload is not enabled.

## 17. Communication & Portal
### Announcements
1. Open Communication & Portal.
2. Enter title and message.
3. Select audience.
4. Publish.
5. Portal users receive relevant notifications according to the configured audience/security rules.

### Notifications
1. Open Notifications.
2. Review messages.
3. Tap Mark read for unread notifications.
4. New notifications can appear in real time.

### Portal Links
1. Select a user.
2. Select the student to link, if applicable.
3. Choose role type.
4. Link the portal profile.
5. Only authorized linked student data is exposed through portal security.

### My Portal
Shows linked student records including:
- Attendance
- Examination results
- Fee assignments/outstanding amount
- Library issues
- Certificates

## 18. Mobile use
- Use the bottom navigation for the most-used sections.
- Use More for the remaining sections.
- Tables can be horizontally scrolled on small screens.
- Forms are designed for touch use.
- Use the theme button to switch light/dark mode.
- Use Refresh after major updates if a screen appears stale.

## 19. Sign out
Use Sign out from the sidebar. Always sign out on shared devices.

## 20. Safe operating routine
Daily:
1. Check Dashboard.
2. Review notifications.
3. Record attendance.
4. Record fee payments and expenses.
5. Update library/inventory movements.
6. Review important audit activity.

Monthly/termly:
1. Review users and branch access.
2. Review roles.
3. Review staff assignments.
4. Review fees and outstanding balances.
5. Review examination results and promotions.
6. Review certificates/documents.

## 21. Troubleshooting
- Blank/white screen: install the latest APK build supplied with the project and ensure the device has internet access.
- Login failure: verify email/password and account status.
- Temporary password account: sign in once and complete the mandatory password-change screen.
- Permission denied: confirm the user has the required role/permission and branch access.
- Missing data: use Refresh and confirm the correct institution/branch context.
- MFA issue: verify the authenticator time/code and factor status.
- Print window not opening: allow pop-ups for the application/web environment.

## 22. Current integration status
Online payments: OFF.
SMS/provider messaging: OFF.
They should be enabled only after the required provider integrations and credentials are configured and tested.

## 23. Security
The application uses Supabase Auth, row-level database authorization and role/permission checks. The frontend must never receive service-role credentials. Supabase documents that ordinary authenticated password changes use updateUser, while admin user updates must remain server-side. 

## 24. Important note
This manual describes the current production build and its implemented workflows. Some advanced integrations, such as direct storage uploads, online payment gateways and provider-based SMS, are intentionally not enabled yet.
