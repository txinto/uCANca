class StateMachineCondition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    description       :text
    implementation    :text
    timestamps
  end
  attr_accessible :name, :description, :implementation

  belongs_to :function_sub_system, :inverse_of => :state_machine_conditions
  has_many :state_machine_transitions, :inverse_of => :state_machine_condition

  validates :implementation, :presence => :true
  validates :name, :presence => :true
  validates :function_sub_system, :presence => :true

  # --- Permissions --- #

  def create_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def update_permitted?
    function_sub_system.updatable_by?(acting_user)
  end

  def destroy_permitted?
    function_sub_system.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    if (function_sub_system) then
      function_sub_system.viewable_by?(acting_user)
    else
      true
    end
  end

end
