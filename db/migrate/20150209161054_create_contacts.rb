class CreateContacts < ActiveRecord::Migration

  def up
    create_table :contacts do |t|
      t.integer :user_id
      t.integer :source, default: 0
      t.string :email
      t.string :name
      t.timestamps
    end
    add_index :contacts, [:user_id, :source, :email], unique: true
    User.all.each do |u|
      EmailForward.where(user_id: u.id).select(:email).distinct.map(&:email).each do |email|
        Contact.create(user_id: u.id, source: :manual, email: email)
      end
    end
  end

  def down
    drop_table :contacts
  end

end
