"""
Test that the is_optional property on parse fields works as expected.
"""

from utils import emit_and_print_errors


ctx = emit_and_print_errors(lkt_file='foo.lkt', types_from_lkt=True)
for n in ctx.astnode_types:
    if n.dsl_name != "ExampleWrapper":
        continue
    for field in n.get_parse_fields():
        print("Field {} is {}".format(
            field.qualname,
            "optional" if field.is_optional else "not optional"
        ))

print('Done')
