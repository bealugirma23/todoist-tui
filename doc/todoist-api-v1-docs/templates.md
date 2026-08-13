# Templates

## POST /templates/import_into_project_from_template_id

Import a saved template into an existing project.

```http
POST /api/v1/templates/import_into_project_from_template_id
```

Body:

- `project_id` — required
- `template_id` — required
- `locale`

## POST /templates/import_into_project_from_file

Import a template file into a project.

```http
POST /api/v1/templates/import_into_project_from_file
```

This is the v1 replacement for the old template import endpoint.

## POST /templates/create_project_from_file

Create a project from a template file.

```http
POST /api/v1/templates/create_project_from_file
```

Multipart form:

- `name` — required
- `file` — required
- `workspace_id`

## GET /templates/file

Export a project as a CSV template.

```http
GET /api/v1/templates/file
```

Query:

- `project_id` — required
- `use_relative_dates`

## GET /templates/url

Export a project as a shareable template URL.

```http
GET /api/v1/templates/url
```

Query:

- `project_id` — required
- `use_relative_dates`
