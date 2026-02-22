"""Visual diff utilities for comparing text strings."""

import difflib
from html import escape


def visual_diff(string1: str, string2: str) -> str:
    """
    Generate an HTML visual diff of two strings.
    
    Args:
        string1: The first string to compare
        string2: The second string to compare
    
    Returns:
        HTML string with highlighted differences:
        - Common text: no highlighting
        - Text only in string1: pastel yellow background
        - Text only in string2: pastel green background
    """
    # Use SequenceMatcher to find differences at character level
    matcher = difflib.SequenceMatcher(None, string1, string2)
    
    html_parts = []
    
    for opcode, i1, i2, j1, j2 in matcher.get_opcodes():
        if opcode == 'equal':
            # Common text - no highlighting
            html_parts.append(escape(string1[i1:i2]))
        elif opcode == 'delete':
            # Text only in string1 - yellow background
            text = escape(string1[i1:i2])
            html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
        elif opcode == 'insert':
            # Text only in string2 - green background
            text = escape(string2[j1:j2])
            html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')
        elif opcode == 'replace':
            # Text changed - show deleted part in yellow and inserted part in green
            if i1 < i2:
                text = escape(string1[i1:i2])
                html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
            if j1 < j2:
                text = escape(string2[j1:j2])
                html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')
    
    return ''.join(html_parts)
