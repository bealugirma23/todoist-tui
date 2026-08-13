# Tasks

## GET /tasks

Get active tasks.

```http
GET /api/v1/tasks
```

Query parameters include:

- `project_id`
- `section_id`
- `parent_id`
- `label`
- `ids` — comma-separated task IDs
- `goal_id`
- `cursor`
- `limit`

## POST /tasks

Create a task.

```http
POST /api/v1/tasks
```

Body fields include:

- `content` — required
- `description`
- `project_id`
- `section_id`
- `parent_id`
- `order`
- `labels`
- `priority`
- `assignee_id`
- `due_string`
- `due_date`
- `due_datetime`
- `due_lang`
- `duration`
- `duration_unit`
- `deadline_date`

Example:

```json
{
  "content": "Buy milk",
  "project_id": "PROJECT_ID",
  "priority": 2,
  "due_string": "tomorrow at 12:00"
}
```

## GET /tasks/filter

Get active tasks matching a Todoist filter.

```http
GET /api/v1/tasks/filter
```

Query parameters:

- `query` — required
- `lang`
- `cursor`
- `limit`

## GET /tasks/{task_id}

Get one active task.

```http
GET /api/v1/tasks/{task_id}
```

Optional query parameter:

- `public_key`

## POST /tasks/{task_id}

Update a task.

```http
POST /api/v1/tasks/{task_id}
```

Common mutable fields:

- `content`
- `description`
- `labels`
- `priority`
- `due_string`
- `due_date`
- `due_datetime`
- `due_lang`
- `assignee_id`
- `duration`
- `duration_unit`
- `deadline_date`
- `child_order`
- `section_id`
- `is_collapsed`
- `day_order`

## DELETE /tasks/{task_id}

Delete a task.

```http
DELETE /api/v1/tasks/{task_id}
```

## POST /tasks/{task_id}/close

Complete a task.

```http
POST /api/v1/tasks/{task_id}/close
```

## POST /tasks/{task_id}/reopen

Reopen a completed task.

```http
POST /api/v1/tasks/{task_id}/reopen
```

## POST /tasks/quick

Quick Add a task using Todoist's natural-language task parser.

```http
POST /api/v1/tasks/quick
```

Example:

```json
{
  "text": "Buy milk tomorrow #Shopping @groceries p1",
  "note": "Remember to check the expiration date",
  "reminder": "tomorrow at 9am",
  "auto_reminder": false,
  "meta": false
}
```

## GET /tasks/completed

Get completed tasks.

```http
GET /api/v1/tasks/completed
```

## GET /tasks/completed/by_completion_date

Get completed tasks constrained by a completion date range.

```http
GET /api/v1/tasks/completed/by_completion_date
```

Important query parameters include:

- `since` — required
- `until`
- `project_id`
- `section_id`
- `parent_id`
- `label`
- `filter`
- `lang`
- `cursor`
- `limit`

The documented completion-date range is limited to a maximum of three months.

## GET /tasks/completed/by_due_date

Get completed tasks grouped/filtered by due-date range.

```http
GET /api/v1/tasks/completed/by_due_date
```

## GET /tasks/completed/stats

Get completed-task/productivity statistics.

```http
GET /api/v1/tasks/completed/stats
```
