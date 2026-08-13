# Sync

## POST /sync

The Sync API is a special API-v1 endpoint intended for efficient synchronization and batching.

```http
POST /api/v1/sync
```

Content type:

```http
Content-Type: application/x-www-form-urlencoded
```

Authentication:

```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

## Reading resources

A full sync can be requested with:

```text
sync_token=*
resource_types=["all"]
```

Incremental sync uses the `sync_token` returned by the previous response.

The response can contain resources such as:

- `user`
- `projects`
- `items`
- `notes`
- `project_notes`
- `sections`
- `labels`
- `filters`
- `workspace_filters`
- `reminders`
- `collaborators`
- `collaborator_states`
- `completed_info`
- `live_notifications`
- `user_settings`
- `user_plan_limits`
- `stats`
- `view_options`
- `workspaces`
- `workspace_users`

## Writing resources

Multiple commands can be submitted in one request using the `commands` form parameter.

Example:

```text
commands=[
  {
    "type": "live_notifications_mark_unread",
    "uuid": "UUID",
    "args": {
      "ids": ["1234"]
    }
  }
]
```

The response contains `sync_status` keyed by command UUID and may contain `temp_id_mapping`.

## Why use Sync?

Use `/sync` when you need:

- multiple changes in one HTTP request
- incremental synchronization
- operations that are only exposed through Sync
- first-party-client-style local state synchronization

## Important v1 changes

- `/sync` is POST-only in API v1.
- `day_orders_timestamp` was removed.
- Full sync responses include `full_sync_date_utc`.
- Client-side `tmp-` IDs are not valid REST IDs. Wait for synchronization to resolve them.

## Sync commands

The official documentation describes many commands, including resource creation/update/deletion and sharing operations. They are commands within this single `/sync` HTTP endpoint rather than separate HTTP endpoints.

Common command families include:

- tasks/items
- projects
- sections
- labels
- comments/notes
- reminders
- collaborators
- invitations
- workspaces
- filters
- live notifications

For the complete command argument schemas, use the official Sync section of the Todoist API documentation.
