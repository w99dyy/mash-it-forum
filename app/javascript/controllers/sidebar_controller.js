import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "collapseIcon", "expandIcon"]

    connect() {
        const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
        if (isCollapsed) {
            this.collapse()
        }
    }

    toggle() {
        const isCollapsed = this.sidebarTarget.classList.contains("w-16")
        if (isCollapsed) {
            this.expand()
        } else {
            this.collapse()
        }
    }

    collapse() {
        this.sidebarTarget.classList.add("w-16")
        this.sidebarTarget.classList.remove("w-64")
        
        // Hide all text spans and badges
        this.sidebarTarget.querySelectorAll("span").forEach(span => {
            span.classList.add("hidden")
        })

        // Center the header (remove justify-between, add justify-center)
        const header = this.sidebarTarget.querySelector('.flex.justify-between')
        if (header) {
            header.classList.remove("justify-between")
            header.classList.add("justify-center")
        }
        
        // Center the links
        this.sidebarTarget.querySelectorAll("li a").forEach(link => {
            link.classList.add("justify-center", "px-0")
            link.classList.remove("pl-2", "gap-3", "px-3")
        })

        // Swap icons: hide collapse, show expand
        this.collapseIconTarget.classList.add("hidden")
        this.expandIconTarget.classList.remove("hidden")
        
        localStorage.setItem("sidebarCollapsed", "true")
    }

    expand() {
        this.sidebarTarget.classList.add("w-64")
        this.sidebarTarget.classList.remove("w-16")
        
        // Show all text spans and badges
        this.sidebarTarget.querySelectorAll("span").forEach(span => {
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

        // Swap icons: hide expand, show collapse
        this.expandIconTarget.classList.add("hidden")
        this.collapseIconTarget.classList.remove("hidden")
        
        localStorage.setItem("sidebarCollapsed", "false")
    }
}