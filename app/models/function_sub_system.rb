class FunctionSubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :sub_system, :function, :sub_system_id, :function_id

  belongs_to :sub_system
  belongs_to :function

  def name
    ret=""
    if (sub_system) then
    ret+="["+sub_system.name+"]"
    end
    if (function) then
      ret+=function.name
    end
    
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
