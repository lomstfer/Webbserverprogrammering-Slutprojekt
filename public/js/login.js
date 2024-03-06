var createAccountStuff = document.getElementById("create_account_stuff");
var loginStuff = document.getElementById("login_stuff");
var showCreateAccountButton = document.getElementById("show_create_account_button");
showCreateAccountButton === null || showCreateAccountButton === void 0 ? void 0 : showCreateAccountButton.addEventListener("click", function () {
    loginStuff.style.display = "none";
    createAccountStuff.style.display = "initial";
    showCreateAccountButton.style.display = "none";
    showLoginButton.style.display = "initial";
});
var showLoginButton = document.getElementById("show_login_button");
showLoginButton === null || showLoginButton === void 0 ? void 0 : showLoginButton.addEventListener("click", function () {
    loginStuff.style.display = "initial";
    createAccountStuff.style.display = "none";
    showCreateAccountButton.style.display = "initial";
    showLoginButton.style.display = "none";
});
