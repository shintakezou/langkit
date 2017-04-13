## vim: filetype=makopython

<%def name="base_decls()">

class _BaseStruct(object):
    """
    Mixin for Ada struct wrappers.
    """

    def __getitem__(self, key):
      if not isinstance(key, int):
         raise TypeError('Tuples items are indexed by integers, not {}'.format(
            type(key)
         ))

      fields = self._c_type._fields_
      if 0 <= key < len(fields):
         field_name, _ = fields[key]
         return getattr(self, field_name)
      else:
         raise IndexError('There is no {}th field'.format(key))

    def __repr__(self):
        field_names = [name for name, _ in self._c_type._fields_]
        return '<{} {}>'.format(
            type(self).__name__,
            ' '.join('{}={}'.format(name, getattr(self, name))
                      for name in field_names)
        )

    # There is no need here to override __del__ as all structure fields already
    # override their own __del__ operators, so structure fields will
    # automatically deallocate themselves when their own Python ref-count will
    # reach 0.

    # Subclasses will override this to a subclass of ctypes.Structure
    _c_type = None

    # If subclasses implement a ref-counted struct, they will override these
    # two to the inc_ref/dec_ref functions.
    _inc_ref = None
    _dec_ref = None


class _BaseEntity(_BaseStruct):
    """
    Specialized mixin for env elements.
    """

    def __getattr__(self, name):
        """
        Evaluate the "name" attribute on the wrapped AST node. This
        automatically passes parents environment rebindings.
        """
        node = self.el
        unbound_public_method = getattr(type(node), name)

        # If there is no private method for this accessor, it means there are
        # no implicit arguments to pass, so just return it.
        try:
            unbound_private_method = getattr(type(node), '_' + name)
        except AttributeError:
            return getattr(node, name)

        def bound_method(*args, **kwargs):
            kwargs[${repr(PropertyDef.env_rebinding_name.lower)}] = \
                self.rebindings
            return unbound_private_method(node, *args, **kwargs)

        # If the public method is actually a property, the caller will not
        # expect a callable to be returned: in this case, call it right now.
        return (bound_method()
                if isinstance(unbound_public_method, property) else
                bound_method)

</%def>

<%def name="decl(cls)">

<%
   type_name = cls.name().camel
   base_classes = ['_BaseEntity'
                   if cls.is_entity_type else
                   '_BaseStruct']
%>

class ${type_name}(${', '.join(base_classes)}):
    ${py_doc(cls, 4)}

    <% field_names = [f.name.lower for f in cls.get_fields()] %>

    __slots__ = (${', '.join(map(repr, field_names))})

    def __init__(self, ${', '.join(field_names)}):
        % for f in field_names:
        self._${f} = ${f}
        % endfor
        % if not field_names:
        pass
        % endif

    % for field in cls.get_fields():

    @property
    def ${field.name.lower}(self):
        ${py_doc(field, 8)}
        return self._${field.name.lower}
    % endfor

    class _c_type(ctypes.Structure):
        _fields_ = [
        % for field in cls.get_fields():
            ('${field.name.lower}',
             ## At this point in the binding, no array type has been emitted
             ## yet, so use a generic pointer: we will do the conversion later
             ## for users.
             % if is_array_type(field.type):
                 ctypes.c_void_p
             % else:
                ${pyapi.type_internal_name(field.type)}
             % endif
             ),
        % endfor
        ]

    @classmethod
    def _wrap(cls, c_value, inc_ref=False):
        result = cls(
            % for field in cls.get_fields():
            <%
                fld = 'c_value.{}'.format(field.name.lower)
                if is_array_type(field.type):
                    fld = 'ctypes.cast({}, {})'.format(
                        fld,
                        pyapi.type_internal_name(field.type)
                    )
                copy = pyapi.wrap_value(fld, field.type,
                                        from_field_access=True)
            %>${copy},
            % endfor
        )
        if cls._inc_ref and inc_ref:
            cls._inc_ref(ctypes.byref(c_value))
        return result

    @classmethod
    def _unwrap(cls, value):
        if not isinstance(value, cls):
            _raise_type_error(cls.__name__, value)

        result = cls._c_type(
            % for f in cls.get_fields():
            <%
                f_access = 'value.{}'.format(f.name.lower)
                unwrapped = pyapi.unwrap_value(f_access, f.type)
            %>
            ${f.name.lower}=${(
                'ctypes.cast({}, ctypes.c_void_p)'.format(unwrapped)
                if is_array_type(f.type) else unwrapped
            )},
            % endfor
        )
        return result

    % if cls.is_refcounted():
    _c_ptr_type = ctypes.POINTER(_c_type)
    _inc_ref = staticmethod(_import_func('${cls.c_inc_ref(capi)}',
                            [_c_ptr_type], None))
    _dec_ref = staticmethod(_import_func('${cls.c_dec_ref(capi)}',
                            [_c_ptr_type], None))
    % endif

</%def>
