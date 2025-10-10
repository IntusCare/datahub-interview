{#
    Formats a phone number from a 10-digit string into XXX-XXX-XXXX display format.

    This macro expects the input field to be a cleaned 10-digit phone number string.
    If the phone number is not exactly 10 digits, it returns NULL.

    Args:
        field: The field containing the cleaned 10-digit phone number

    Returns:
        Formatted phone number as XXX-XXX-XXXX or NULL if invalid

    Example:
        {{ format_phone_number('phone_cleaned') }}
        Input: '2125551234'
        Output: '212-555-1234'
#}
{% macro format_phone_number(field) %}
    case
        when length({{ field }}) != 10
        then null
        else
            substr({{ field }}, 1, 3)
            || '-'
            || substr({{ field }}, 4, 3)
            || '-'
            || substr({{ field }}, 7, 4)
    end
{% endmacro %}
