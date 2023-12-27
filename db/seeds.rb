user = User.create!(
  first_name: "Tester",
  last_name: "Test",
  email: "testemail@testdomain.moc",
  password: "12341234"
)

family = Family.create!(
  owner: user,
  name: "Test Family",
)

Budget.create!(family: family, name: "Food", icon: "", amount: 500)
Budget.create!(family: family, name: "Gas", icon: "fa-solid fa-gas-pump", amount: 150)
Budget.create!(family: family, name: "Entertainment", icon: "fa-solid fa-volleyball", amount: 300)
Budget.create!(family: family, name: "Home", icon: "fa-solid fa-house", amount: 300)
Budget.create!(family: family, name: "Other", icon: "fa-solid fa-info", amount: 500)
Budget.create!(family: family, name: "Gifts", icon: "fa-solid fa-mug-hot", amount: 300, private: true)
