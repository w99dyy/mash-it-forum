import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "hideSideBar"]

    connect() {
        const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
        if (isCollapsed) {
            this.collapse()
        }
    }

    toggle() {
        const isCollapsed = this.sidebarTarget.classList.contains("w-0")
        if (isCollapsed) {
            this.expand()
        } else {
            this.collapse()
        }
    }

    collapse() {
        this.sidebarTarget.classList.add("w-0")
        this.sidebarTarget.classList.remove("w-64")
        
        // Hide all text spans and badges
        this.sidebarTarget.querySelectorAll("span, svg, a").forEach(span => {
            span.classList.add("hidden")
        })
        this.sidebarTarget.classList.add("collapsed")
        
        localStorage.setItem("sidebarCollapsed", "true")
    }

    expand() {
        this.sidebarTarget.classList.add("w-64")
        this.sidebarTarget.classList.remove("w-0")
        
        // Show all text spans and badges
        this.sidebarTarget.querySelectorAll("span, svg, a").forEach(span => {
            span.classList.remove("hidden")
        })
        
        // Reset header (add justify-between back)
        const header = this.sidebarTarget.querySelector('.flex.justify-center')
        if (header) {
            header.classList.remove("justify-center")
            header.classList.add("justify-between")
        }
        
        // Reset links
        this.sidebarTarget.querySelectorAll("li a").forEach(link => {
            link.classList.remove("justify-center", "px-0")
            link.classList.add("pl-2", "gap-3", "px-3")
        })
        this.sidebarTarget.classList.remove("collapsed")
        localStorage.setItem("sidebarCollapsed", "false")
    }
}