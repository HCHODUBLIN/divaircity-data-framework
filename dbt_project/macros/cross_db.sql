{% macro current_timestamp_utc() %}
  {% if target.type == 'duckdb' %}
    now()
  {% else %}
    CURRENT_TIMESTAMP()
  {% endif %}
{% endmacro %}

{% macro type_timestamp() %}
  {% if target.type == 'duckdb' %}
    TIMESTAMP
  {% else %}
    TIMESTAMP_NTZ
  {% endif %}
{% endmacro %}
