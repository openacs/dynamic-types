<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<p>#dynamic-types.code_necessary#</p>
<pre style="border: 1px solid #CCC; background-color: #EEE; padding: 10px;">
set default_locale [lang::system::site_wide_locale]
<multiple name=types>
<include src="/packages/dynamic-types/lib/dtype-code" object_type="@types.object_type@">
</multiple>
</pre>
