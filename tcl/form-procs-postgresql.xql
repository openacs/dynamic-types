<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dtype::form::metadata::create_widget.create_widget">      
      <querytext>

          select dtype_widget__register_form_widget (
                :object_type,
                :dform,
                :attribute_name,
                :widget,
                :required_p,
                :create_form_p
          );

      </querytext>
</fullquery>

<fullquery name="dtype::form::metadata::delete_widget.delete_widget">      
      <querytext>

          select dtype_widget__unregister_form_widget (
                :object_type,
                :dform,
                :attribute_name,
                :delete_form_p
          );

      </querytext>
</fullquery>

<fullquery name="dtype::form::metadata::delete_attribute_widgets.get_widget_forms">
      <querytext>
          select f.name as dform
            from dtype_form_elements fe,
                 dtype_forms f,
                 acs_attributes a
           where fe.form_id = f.form_id
             and a.attribute_id = fe.attribute_id
             and a.object_type = :object_type
             and a.attribute_name = :attribute_name
      </querytext>
</fullquery>

<fullquery name="dtype::form::metadata::create_widget_param.create_widget_param">      
      <querytext>

          select dtype_widget__set_param_value (
                :object_type,
                :dform,
                :attribute_name,
                :param_name,
                :value,
                :type,
                :source
          );

      </querytext>
</fullquery>

<fullquery name="dtype::form::types_list.supertypes">      
      <querytext>
        select o2.object_type
          from acs_object_types o1, 
               acs_object_types o2
         where o1.object_type = :object_type
           and o2.tree_sortkey <= o1.tree_sortkey
           and o1.tree_sortkey between o2.tree_sortkey 
                                   and tree_right(o2.tree_sortkey)
         order by tree_level(o2.tree_sortkey) desc
      </querytext>
</fullquery>

<fullquery name="dtype::form::types_list.instance_supertypes">      
      <querytext>
        select o2.object_type
          from acs_object_types o1, 
               acs_object_types o2,
               acs_objects o
         where o.object_id = :object_id
           and o1.object_type = o.object_type
           and o2.tree_sortkey <= o1.tree_sortkey
           and o1.tree_sortkey between o2.tree_sortkey 
                                   and tree_right(o2.tree_sortkey)
         order by tree_level(o2.tree_sortkey) desc
      </querytext>
</fullquery>

<fullquery name="dtype::form::process.create_item">      
      <querytext>
        select content_item__new(varchar :item_name,
                                 :item_parent_id,
                                 :item_item_id,
                                 :item_locale,
                                 now(),
                                 :item_creation_user,
                                 :item_context_id,
                                 :item_creation_ip,
                                 'content_item',
                                 :item_content_type,
                                 null,
                                 null,
                                 'text/plain',
                                 null,
                                 null,
                                 :cr_storage,
				 :item_package_id)
      </querytext>
</fullquery>

<fullquery name="dtype::upload_content.upload_text_revision">      
      <querytext>

        update 
          cr_revisions 
        set 
          content = '[DoubleApos [read [set __f [open $file r]]]][close $__f]',
          content_length = [file size $file]
        where 
          revision_id = :revision_id
      
      </querytext>
</fullquery>


<fullquery name="dtype::upload_content.upload_revision">      
      <querytext>

             update cr_revisions 
             set lob = [set __lob_id [db_string new_lob "select empty_lob()"]],
             content_length = [file size $file]
             where revision_id = :revision_id
      
      </querytext>
</fullquery>


<fullquery name="dtype::upload_content.upload_file_revision">      
      <querytext>

        update cr_revisions 
        set content = '[set file_path [cr_create_content_file $item_id $revision_id $file]]',
        content_length = '[cr_file_size $file_path]'
        where revision_id = :revision_id

      </querytext>
</fullquery>

<partialquery name="dtype::form::process.latest_revision">      
      <querytext>
      content_item__get_latest_revision(:item_id)
      </querytext>
</partialquery>
</queryset>
