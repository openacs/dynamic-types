<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dtype::upload_content.upload_file_revision">      
      <querytext>

      update cr_revisions 
      set filename =:file_path, content_length = :file_size
      where revision_id = :revision_id
    
      </querytext>
</fullquery>

<fullquery name="dtype::upload_content.upload_text_revision">      
      <querytext>

             update cr_revisions 
             set content = empty_blob(), 
             content_length = [file size $file] 
             where revision_id = :revision_id
             returning content into :1
      
      </querytext>
</fullquery>

<fullquery name="dtype::upload_content.upload_revision">      
      <querytext>

             update cr_revisions 
             set content = empty_blob(), 
             content_length = [file size $file]
             where revision_id = :revision_id
             returning content into :1
      
      </querytext>
</fullquery>

<partialquery name="dtype::form::process.latest_revision">      
      <querytext>
      content_item.get_latest_revision(:item_id)
      </querytext>
</partialquery>
</queryset>
