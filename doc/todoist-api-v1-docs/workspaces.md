# Workspaces

## GET /workspaces

List workspaces where the user is a member.

```http
GET /api/v1/workspaces
```

## POST /workspaces

Create a workspace.

```http
POST /api/v1/workspaces
```

Common body fields:

- `name`
- `description`
- `is_link_sharing_enabled`
- `is_guest_allowed`
- `domain_name`
- `domain_discovery`
- `restrict_email_domains`
- `properties`
- `is_trial_pending`

## GET /workspaces/{workspace_id}

Get one workspace.

```http
GET /api/v1/workspaces/{workspace_id}
```

## POST /workspaces/{workspace_id}

Update a workspace.

```http
POST /api/v1/workspaces/{workspace_id}
```

## DELETE /workspaces/{workspace_id}

Delete a workspace.

```http
DELETE /api/v1/workspaces/{workspace_id}
```

## POST /workspaces/join

Join a workspace using an invite code or eligible workspace ID.

```http
POST /api/v1/workspaces/join
```

Provide either `invite_code` or `workspace_id`.

## GET /workspaces/joinable

List workspaces the current user can join.

```http
GET /api/v1/workspaces/joinable
```

## GET /workspaces/{workspace_id}/projects/active

List active workspace projects.

```http
GET /api/v1/workspaces/{workspace_id}/projects/active
```

Query:

- `cursor`
- `limit`

## GET /workspaces/{workspace_id}/projects/archived

List archived workspace projects.

```http
GET /api/v1/workspaces/{workspace_id}/projects/archived
```

Query:

- `cursor`
- `limit`

## GET /workspaces/users

List workspace users.

```http
GET /api/v1/workspaces/users
```

Query:

- `workspace_id`
- `cursor`
- `limit`

## POST /workspaces/{workspace_id}/users/invite

Invite users to a workspace.

```http
POST /api/v1/workspaces/{workspace_id}/users/invite
```

Body:

- `email_list`
- `role`

## DELETE /workspaces/{workspace_id}/users/{user_id}

Remove a user from a workspace.

```http
DELETE /api/v1/workspaces/{workspace_id}/users/{user_id}
```

## POST /workspaces/{workspace_id}/users/{user_id}

Update a workspace user's role.

```http
POST /api/v1/workspaces/{workspace_id}/users/{user_id}
```

Roles include:

- `ADMIN`
- `MEMBER`
- `GUEST`

## GET /workspaces/invitations

List pending invitation emails.

```http
GET /api/v1/workspaces/invitations
```

Query:

- `workspace_id` — required

## GET /workspaces/invitations/all

Get detailed pending invitations.

```http
GET /api/v1/workspaces/invitations/all
```

Query:

- `workspace_id` — required

## POST /workspaces/invitations/delete

Delete a workspace invitation.

```http
POST /api/v1/workspaces/invitations/delete
```

Body:

- `workspace_id`
- `user_email`

## PUT /workspaces/invitations/{invite_code}/accept

Accept a workspace invitation.

```http
PUT /api/v1/workspaces/invitations/{invite_code}/accept
```

## PUT /workspaces/invitations/{invite_code}/reject

Reject a workspace invitation.

```http
PUT /api/v1/workspaces/invitations/{invite_code}/reject
```

## POST /workspaces/logo

Upload/delete a workspace logo.

```http
POST /api/v1/workspaces/logo
```

Multipart form:

- `workspace_id`
- `delete`
- `file`

## GET /workspaces/plan_details

Get workspace plan and usage details.

```http
GET /api/v1/workspaces/plan_details
```

Query:

- `workspace_id`
