import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar"]

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
        this.sidebarTarget.classList.remove("w-1/7")
        
        this.sidebarTarget.querySelectorAll("li span, .nav-text").forEach(span => {
            span.classList.add("hidden")
        })
        
        this.sidebarTarget.querySelectorAll("li a").forEach(link => {
            link.classList.add("justify-center", "pl-0")
            link.classList.remove("pl-2", "gap-3")
        })
        
        localStorage.setItem("sidebarCollapsed", "true")
    }

    expand() {
        this.sidebarTarget.classList.add("w-1/7")
        this.sidebarTarget.classList.remove("w-16")
        
        this.sidebarTarget.querySelectorAll("li span, .nav-text").forEach(span => {
            span.classList.remove("hidden")
        })
        
        this.sidebarTarget.querySelectorAll("li a").forEach(link => {
            link.classList.remove("justify-center", "pl-0")
            link.classList.add("pl-2", "gap-3")
        })
        
        localStorage.setItem("sidebarCollapsed", "false")
    }
}