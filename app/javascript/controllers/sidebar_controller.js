import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "hideSideBar", "backdrop"]

    connect() {
        if (window.innerWidth < 768) {
            this.sidebarTarget.classList.add("-translate-x-full")
            return
        }

        // desktop
        const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
        if (isCollapsed) {
            this.sidebarTarget.classList.add("-translate-x-full", "w-0")
            this.sidebarTarget.classList.remove("w-64")
        } else {
            this.sidebarTarget.classList.remove("-translate-x-full", "w-0")
            this.sidebarTarget.classList.add("w-64")
        }
    }
    toggle() {
        const isCollapsed = this.sidebarTarget.classList.contains("-translate-x-full")
        if (isCollapsed) {
            this.expand()
        } else {
            this.collapse()
        }
    }

 collapse() {
        // Animate out
        this.sidebarTarget.classList.add("-translate-x-full")
        
        // Remove width AFTER animation completes (300ms)
        setTimeout(() => {
            this.sidebarTarget.classList.add("w-0")
            this.sidebarTarget.classList.remove("w-64")
        }, 300)
        
        if (this.hasBackdropTarget) {
            this.backdropTarget.classList.add("hidden")
        }
         
        localStorage.setItem("sidebarCollapsed", "true")
    }

    expand() {
        // Restore width BEFORE animation starts
        this.sidebarTarget.classList.add("w-64")
        this.sidebarTarget.classList.remove("w-0")
        
        // Force reflow to ensure width is applied
        void this.sidebarTarget.offsetWidth
        
        // Animate in
        this.sidebarTarget.classList.remove("-translate-x-full")

        if (window.innerWidth < 768 && this.hasBackdropTarget) {
            this.backdropTarget.classList.remove("hidden")
        }
        
        localStorage.setItem("sidebarCollapsed", "false")
    }
}
