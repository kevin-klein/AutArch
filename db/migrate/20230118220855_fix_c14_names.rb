class FixC14Names < ActiveRecord::Migration[7.0]
  def change
    change_table :c14_dates do |t|
      t.rename :calbc_1sigma_max, :calbc_1_sigma_max
      t.rename :calbc_2sigma_max, :calbc_2_sigma_max
      t.rename :calbc_2sigma_min, :calbc_2_sigma_min
    end
  end
end
