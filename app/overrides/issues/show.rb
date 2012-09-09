Deface::Override.new :virtual_path  => 'issues/show',
                     :original      => '5c9c7359c91d5e72ad98984f169dcb0abf65173a',
                     :name          => 'add-configuration-items-to-issues',
                     :insert_after  => 'table.attributes',
                     :text          => '<%= render :partial => "configuration_items" %>'

