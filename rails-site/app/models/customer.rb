
class Customer < ActiveRecord::Base
  belongs_to :salesperson
  include SqlUtils

  def update_fields
      SqlUtils.execute_sql()
  end
end
