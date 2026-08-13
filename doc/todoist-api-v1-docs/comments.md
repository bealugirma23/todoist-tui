# Comments

Comments can belong to either a task or a project.

## GET /comments

List comments for a task or project.

```http
GET /api/v1/comments
```

Exactly one of these is required:

- `task_id`
- `project_id`

Also supports:

- `cursor`
- `limit`
- `public_key`

## POST /comments

Create a comment.

```http
POST /api/v1/comments
```

Body:

- `content` — required
- `task_id` or `project_id` — exactly one
- `attachment`
- `uids_to_notify`

## GET /comments/{comment_id}

Get one comment.

```http
GET /api/v1/comments/{comment_id}
```

## DELETE /comments/{comment_id}

Delete a comment.

```http
DELETE /api/v1/comments/{comment_id}
```
