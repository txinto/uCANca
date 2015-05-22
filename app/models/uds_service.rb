class UdsService < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident                 :string
    name                  :string
    length                :integer
    app_session_default   :boolean
    app_session_prog      :boolean
    app_session_extended  :boolean
    app_session_supplier  :boolean
    boot_session_default  :boolean
    boot_session_prog     :boolean
    boot_session_extended :boolean
    boot_session_supplier :boolean
    sec_locked            :boolean
    sec_lev1              :boolean
    sec_lev_11            :boolean
    sec_supplier          :boolean
    addr_phys             :boolean
    addr_func             :boolean
    supress_bit           :boolean
    precondition          :boolean
    timestamps
  end
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :configuration_switch, :configuration_switch_id

  belongs_to :project, :creator => :true, :inverse_of => :uds_services
  belongs_to :configuration_switch, :inverse_of => :uds_services

has_many :uds_sub_services, :dependent => :destroy, :inverse_of => :uds_service
has_many :uds_service_fixed_params, :dependent => :destroy, :inverse_of => :uds_service
has_many :uds_service_identifiers, :dependent => :destroy, :inverse_of => :uds_service

  validates :project, :presence => :true
  
children :uds_sub_services

  
    def to_serv_c(index)
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
    retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    retinit+="\tuds_serv_id_indexes["+index.to_s+"]=UDS_SERV_"+self.c_define_name+"_ID;\n"
    retinit+="\tuds_serv_permission_session_default["+index.to_s+"]="+boolean_to_s(self.app_session_default)+";\n"
    retinit+="\tuds_serv_permission_session_prog["+index.to_s+"]="+boolean_to_s(self.app_session_prog)+";\n"
    retinit+="\tuds_serv_permission_session_extended["+index.to_s+"]="+boolean_to_s(self.app_session_extended)+";\n"
    retinit+="\tuds_serv_permission_session_supplier["+index.to_s+"]="+boolean_to_s(self.app_session_supplier)+";\n"
    retinit+="\tuds_serv_permission_security_locked["+index.to_s+"]="+boolean_to_s(self.sec_locked)+";\n"
    retinit+="\tuds_serv_permission_security_level1["+index.to_s+"]="+boolean_to_s(self.sec_lev1)+";\n"
    retinit+="\tuds_serv_permission_security_level11["+index.to_s+"]="+boolean_to_s(self.sec_lev_11)+";\n"
    retinit+="\tuds_serv_permission_security_supplier["+index.to_s+"]="+boolean_to_s(self.sec_supplier)+";\n"
    retinit+="\tuds_serv_permission_addressing_physical["+index.to_s+"]="+boolean_to_s(self.addr_phys)+";\n"
    retinit+="\tuds_serv_permission_addressing_functional["+index.to_s+"]="+boolean_to_s(self.addr_func)+";\n"

    ret+="BOOL UDSServ_"+self.c_name+"(UI_8 *data_buffer, UI_8 index, UI_8 *data_size)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    retswitch +="        case UDS_SERV_"+self.c_define_name+"_ID: 
            if (UDSServ_check_permissions(id,&response_mode)==TRUE){ 
                if (UDSServ_"+self.c_name+"(resp->buffer_dades,resp_pos,&data_size)==TRUE){ 
                    response_mode=ISO15765_3_POSITIVE_RESPONSE; 
                    Iso15765_3IncrementResponseSize(data_size); 
                } 
            } 
            break; 
"
    if (configuration_switch!=nil) then
    retinit+="#endif\n"
    ret+="#endif\n"
    retswitch+="#endif\n"
    end

    return ret,retswitch,retinit
  end
  
  def to_serv_h
    ret="#define UDS_SERV_"+self.c_define_name+"_ID                 ((UI_16)0x"+self.ident.upcase+")\n"
    ret+="#define UDS_SERV_"+self.c_define_name+"_LEN                 ((UI_8)"+self.length.to_s+")\n"
    ret+="\nBOOL UDSServ_"+self.c_define_name+"(UI_8 *data_buffer, UI_8 index, UI_8 *data_size);\n"
    
    return ret
  end
  
  def boolean_to_s(value)
    if value==true then
      "TRUE"
    else
      "FALSE"
    end
  end

  def c_name
    name.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '').gsub('-','_')
  end
  
  def c_define_name
    c_name.upcase
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
