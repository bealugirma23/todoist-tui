# User, Activity & Settings

## GET /user

Get information about the authenticated user.

```http
GET /api/v1/user
```

This is the OIDC userinfo endpoint and requires the appropriate user-read permission.

## GET /activities

Get the activity log.

```http
GET /api/v1/activities
```

Important query parameters include:

- `object_type`
- `object_id`
- `parent_project_id`
- `parent_item_id`
- `event_type` / event-type filters
- `cursor`
- `limit`

Supported object types include:

- `project`
- `item` (task)
- `note` (comment)
- `section`

The activity endpoint uses cursor pagination.

## PUT /notification_setting

Update notification preferences.

```http
PUT /api/v1/notification_setting
```

See `reminders.md` for the request shape.
