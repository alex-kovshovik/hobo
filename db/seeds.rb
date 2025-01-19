password_digest = BCrypt::Password.create("12341234")

user = User.create!(
  email_address: "test@test.com",
  password_digest: password_digest,

  first_name: "Tester",
  last_name: "Test"
)

family = Family.create!(
  name: "Test Family Group",
)

user.update!(family: family)

Budget.create!(family: family, name: "Food", icon: "fa-solid fa-cart-shopping", amount: 500)
Budget.create!(family: family, name: "Gas", icon: "fa-solid fa-gas-pump", amount: 150)
Budget.create!(family: family, name: "Entertainment", icon: "fa-solid fa-volleyball", amount: 300)
Budget.create!(family: family, name: "Home", icon: "fa-solid fa-house", amount: 300)
Budget.create!(family: family, name: "Other", icon: "fa-solid fa-info", amount: 500)
Budget.create!(family: family, name: "Gifts", icon: "fa-solid fa-mug-hot", amount: 300, private: true)
