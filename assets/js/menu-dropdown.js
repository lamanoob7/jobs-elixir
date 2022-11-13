const menuButton = document.getElementById('menu-dropdown');
const dropdown = document.getElementById('header').querySelector('.dropdown');

const menuControl = () => {
  if (dropdown.classList.contains('-right-28')) {

    dropdown.classList.add('right-0');
    dropdown.classList.remove('-right-28');

  } else if (dropdown.classList.contains('right-0')) {

    dropdown.classList.remove('right-0');
    dropdown.classList.add('-right-28');

  }
}

export const menuDropdown = () => {
  menuButton.addEventListener("click", menuControl);
}
