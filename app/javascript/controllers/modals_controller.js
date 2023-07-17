import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modals"
export default class extends Controller {
  connect() {
    const esc = (e) => {
      if (e.keyCode == 27) {
        this.close();
      }
    }
    document.addEventListener("keydown", esc)
  }

  close(e) {
    // Remove from parent
    const modal = document.getElementById("modal");
    modal.innerHTML = "";

    // Remove the src attribute from the modal
    modal.removeAttribute("src");
  }
}
