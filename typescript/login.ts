// const req = new XMLHttpRequest()
// req.open("POST", "/testinge")
// req.send()

const createAccountStuff = document.getElementById("create_account_stuff")
const loginStuff = document.getElementById("login_stuff")

const showCreateAccountButton = document.getElementById("show_create_account_button")
showCreateAccountButton?.addEventListener("click", () => {
    loginStuff.style.display = "none"
    createAccountStuff.style.display = "initial"
    showCreateAccountButton.style.display = "none"
    showLoginButton.style.display = "initial"
})

const showLoginButton = document.getElementById("show_login_button")
showLoginButton?.addEventListener("click", () => {
    loginStuff.style.display = "initial"
    createAccountStuff.style.display = "none"
    showCreateAccountButton.style.display = "initial"
    showLoginButton.style.display = "none"
})