class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :country
      t.string :department
      t.string :job_title
      t.integer :salary_cents
      t.string :currency
      t.date :hired_on

      t.timestamps
    end
    add_index :employees, :email, unique: true
    add_index :employees, :country
    add_index :employees, :department
    add_index :employees, :salary_cents
  end
end
