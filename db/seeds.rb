user = User.create!(
  email_address: "test@test.com",
  password: "12341234",
  first_name: "Tester",
  last_name: "Test"
)

family = Family.create!(
  name: "Kovshoviks Family",
)

user.update!(family: family)

Budget.create!(family: family, name: "Food", icon: "fa-solid fa-cart-shopping", amount: 1800)
Budget.create!(family: family, name: "Gas", icon: "fa-solid fa-gas-pump", amount: 150)
Budget.create!(family: family, name: "Lunch", icon: "fa-solid fa-utensils", amount: 300)
Budget.create!(family: family, name: "Badass", icon: "fa-solid fa-capsules", amount: 300)
