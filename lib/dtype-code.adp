
############
# Object Type "@object_type@"
############
<multiple name="attributes">
dtype::create_attribute \
       -object_type {@object_type@} \
       -name {@attributes.attribute_name@} \
       -data_type {@attributes.datatype@} \
       -pretty_name {@attributes.pretty_name@} \
       -pretty_plural {@attributes.pretty_plural@} \
       -default_value {@attributes.default_value@}
lang::message::register \
       -update_sync $default_locale acs-translations \
       {@object_type@_@attributes.attribute_name@} {@attributes.pretty_name@}
lang::message::register \
       -update_sync $default_locale acs-translations \
       {@object_type@_@attributes.attribute_name@s} {@attributes.pretty_plural@}
</multiple>

<multiple name="forms">
# Form "@forms.form_name@"
dtype::form::new -object_type {@object_type@} -form_name {@forms.form_name@}
<group column="form_id">
dtype::form::metadata::create_widget \
       -object_type {@object_type@} \
       -dform {@forms.form_name@} \
       -attribute_name {@forms.attribute_name@} \
       -widget {@forms.widget@} \
       -required_p {@forms.is_required@}
<group column="element_id">
<if @forms.param@ not nil>
dtype::form::metadata::create_widget_param \
       -object_type {@object_type@} \
       -dform {@forms.form_name@} \
       -attribute_name {@forms.attribute_name@} \
       -param_name {@forms.param@} \
       -type {@forms.param_type@} \
       -source {@forms.param_source@} \
       -value {@forms.param_value@}
</if>
</group>
</group>

</multiple>
