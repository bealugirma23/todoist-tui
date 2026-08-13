# Complete API v1 Endpoint Manifest

All paths below use `https://api.todoist.com` as the host unless noted otherwise.

## API v1

| Method | Path |
|---|---|
| POST | `/api/v1/access_tokens/migrate_personal_token` |
| DELETE | `/api/v1/access_tokens` |
| POST | `/api/v1/revoke` |
| POST | `/api/v1/sync` |
| GET | `/api/v1/tasks` |
| POST | `/api/v1/tasks` |
| GET | `/api/v1/tasks/filter` |
| GET | `/api/v1/tasks/{task_id}` |
| POST | `/api/v1/tasks/{task_id}` |
| DELETE | `/api/v1/tasks/{task_id}` |
| POST | `/api/v1/tasks/{task_id}/close` |
| POST | `/api/v1/tasks/{task_id}/reopen` |
| POST | `/api/v1/tasks/quick` |
| GET | `/api/v1/tasks/completed` |
| GET | `/api/v1/tasks/completed/by_completion_date` |
| GET | `/api/v1/tasks/completed/by_due_date` |
| GET | `/api/v1/tasks/completed/stats` |
| GET | `/api/v1/projects` |
| POST | `/api/v1/projects` |
| GET | `/api/v1/projects/{project_id}` |
| POST | `/api/v1/projects/{project_id}` |
| DELETE | `/api/v1/projects/{project_id}` |
| POST | `/api/v1/projects/{project_id}/archive` |
| POST | `/api/v1/projects/{project_id}/unarchive` |
| POST | `/api/v1/projects/{project_id}/join` |
| GET | `/api/v1/projects/archived` |
| GET | `/api/v1/projects/search` |
| GET | `/api/v1/projects/{project_id}/collaborators` |
| GET | `/api/v1/projects/{project_id}/full` |
| GET | `/api/v1/projects/permissions` |
| GET | `/api/v1/sections` |
| POST | `/api/v1/sections` |
| GET | `/api/v1/sections/{section_id}` |
| POST | `/api/v1/sections/{section_id}` |
| DELETE | `/api/v1/sections/{section_id}` |
| POST | `/api/v1/sections/{section_id}/archive` |
| POST | `/api/v1/sections/{section_id}/unarchive` |
| GET | `/api/v1/sections/search` |
| GET | `/api/v1/labels` |
| POST | `/api/v1/labels` |
| GET | `/api/v1/labels/{label_id}` |
| POST | `/api/v1/labels/{label_id}` |
| DELETE | `/api/v1/labels/{label_id}` |
| GET | `/api/v1/labels/search` |
| GET | `/api/v1/labels/shared` |
| POST | `/api/v1/labels/shared/rename` |
| POST | `/api/v1/labels/shared/remove` |
| GET | `/api/v1/comments` |
| POST | `/api/v1/comments` |
| GET | `/api/v1/comments/{comment_id}` |
| DELETE | `/api/v1/comments/{comment_id}` |
| GET | `/api/v1/folders` |
| POST | `/api/v1/folders` |
| POST | `/api/v1/folders/{folder_id}` |
| DELETE | `/api/v1/folders/{folder_id}` |
| GET | `/api/v1/workspaces` |
| POST | `/api/v1/workspaces` |
| GET | `/api/v1/workspaces/{workspace_id}` |
| POST | `/api/v1/workspaces/{workspace_id}` |
| DELETE | `/api/v1/workspaces/{workspace_id}` |
| POST | `/api/v1/workspaces/join` |
| GET | `/api/v1/workspaces/joinable` |
| GET | `/api/v1/workspaces/{workspace_id}/projects/active` |
| GET | `/api/v1/workspaces/{workspace_id}/projects/archived` |
| GET | `/api/v1/workspaces/users` |
| POST | `/api/v1/workspaces/{workspace_id}/users/invite` |
| DELETE | `/api/v1/workspaces/{workspace_id}/users/{user_id}` |
| POST | `/api/v1/workspaces/{workspace_id}/users/{user_id}` |
| GET | `/api/v1/workspaces/invitations` |
| GET | `/api/v1/workspaces/invitations/all` |
| POST | `/api/v1/workspaces/invitations/delete` |
| PUT | `/api/v1/workspaces/invitations/{invite_code}/accept` |
| PUT | `/api/v1/workspaces/invitations/{invite_code}/reject` |
| POST | `/api/v1/workspaces/logo` |
| GET | `/api/v1/workspaces/plan_details` |
| GET | `/api/v1/reminders` |
| GET | `/api/v1/reminders/{reminder_id}` |
| POST | `/api/v1/reminders/{reminder_id}` |
| DELETE | `/api/v1/reminders/{reminder_id}` |
| PUT | `/api/v1/notification_setting` |
| POST | `/api/v1/templates/import_into_project_from_template_id` |
| POST | `/api/v1/templates/import_into_project_from_file` |
| POST | `/api/v1/templates/create_project_from_file` |
| GET | `/api/v1/templates/file` |
| GET | `/api/v1/templates/url` |
| POST | `/api/v1/uploads` |
| GET | `/api/v1/uploads` |
| DELETE | `/api/v1/uploads` |
| GET | `/api/v1/backups` |
| GET | `/api/v1/backups/download` |
| GET | `/api/v1/user` |
| GET | `/api/v1/activities` |
| GET | `/api/v1/id_mappings/{obj_name}/{obj_ids}` |

## OAuth endpoints outside `/api/v1`

| Method | Path |
|---|---|
| GET | `https://app.todoist.com/oauth/authorize` |
| POST | `https://api.todoist.com/oauth/access_token` |

## Source

https://developer.todoist.com/api/v1/
