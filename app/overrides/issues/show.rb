Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-configuration-items-to-issues',
                     :insert_after  => 'table.attributes',
                     :text          => '<%= render :partial => "configuration_items" %>'

