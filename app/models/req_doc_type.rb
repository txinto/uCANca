class ReqDocType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    abbrev :string
    timestamps
  end
  attr_accessible :name, :abbrev
  
  has_many :req_docs, :inverse_of => :req_doc_type
 
  validates :name, :presence => :true
  validates :abbrev, :presence => :true

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
