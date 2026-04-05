# Apache Airflow Contribution Reference

## Template Rendering Tests

Use the `create_task_instance_of_operator` fixture for testing template_fields:

```python
@pytest.mark.db_test
def test_render_template(create_task_instance_of_operator):
    ti = create_task_instance_of_operator(
        MyOperator,
        dag_id="test_dag",
        task_id="test_task",
        param1="{{ ds }}",
        param2="{{ var.value.my_var }}",
    )
    ti.render_templates()
    assert ti.task.param1 == "2024-01-01"
```

Do NOT use `dag_maker` for template rendering tests - it does not properly initialize the rendering context.

## DB Test Marker

Any test that touches the Airflow metadata database must be marked:

```python
@pytest.mark.db_test
def test_something_with_db():
    ...
```

## Import Style

```python
from __future__ import annotations

import os
from typing import TYPE_CHECKING

from airflow.models import BaseOperator
from airflow.providers.xxx.hooks.xxx import XxxHook

if TYPE_CHECKING:
    from airflow.utils.context import Context
```

## PR Template

Airflow requires:
- Description of changes
- Testing done
- AI disclosure checkbox (must be checked and filled honestly)
- Link to related issue

## Commit Message Format

`[component] Short description`

Example: `[providers/salesforce] Add template_fields to SalesforceBulkOperator`
