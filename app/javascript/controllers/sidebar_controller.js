import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "hideSideBar", "backdrop"]

    connect() {
        const isMobile = window.innerWidth < 768
        // sidebar default is closed on mobile
        if(isMobile) {
            this.sidebarTarget.classList.add("hidden")
            this.sidebarTarget.classList.remove("md:flex")
            localStorage.setItem("sidebarOpen", "false")
        } else {
            // Default on dekstop is opened
            const isOpen = localStorage.getItem("sidebarOpen") !== "false"
            if (isOpen) {
                this.sidebarTarget.classList.remove("hidden")
                this.sidebarTarget.classList.add("flex")
            }
        }
        
        
        const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
        if (isCollapsed) {
            this.collapse()
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
        this.sidebarTarget.classList.add("-translate-x-full")
        this.sidebarTarget.classList.add("hidden")
        this.backdropTarget.classList.add("hidden")
        // Hide all text spans and badges
        this.sidebarTarget.querySelectorAll("span, svg, a").forEach(span => {
            span.classList.add("hidden")
        })
        this.sidebarTarget.classList.add("collapsed")
        
        localStorage.setItem("sidebarCollapsed", "true")
    }

    expand() {
        this.sidebarTarget.classList.remove("-translate-x-full")
        this.sidebarTarget.classList.remove("hidden")

        if (window.innerWidth < 768) {
            this.backdropTarget.classList.remove("hidden")
        }
        
        // Show all text spans and badges
        this.sidebarTarget.querySelectorAll("span, svg, a").forEach(span => {
            span.classList.remove("hidden")
        })
      
        localStorage.setItem("sidebarCollapsed", "false")
    }
}
