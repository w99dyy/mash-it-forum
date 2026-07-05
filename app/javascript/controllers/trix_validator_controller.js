import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-file-accept", this.validateFileBeforeUpload.bind(this))
    this.element.addEventListener("trix-attachment-add", this.handleUpload.bind(this))
  }
  
  validateFileBeforeUpload(event) {
    const file = event.file
    
    if (!file) return
    
    const validTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    const maxSize = 10 * 1024 * 1024
    
    if (!validTypes.includes(file.type)) {
      event.preventDefault()
      this.showError("Only JPEG, PNG, GIF, and WebP images are allowed.")
      return false
    }
    
    if (file.size > maxSize) {
      event.preventDefault()
      this.showError(`Image is too large (${(file.size / 1024 / 1024).toFixed(1)}MB). Maximum is 10MB.`)
      return false
    }
    
    return true
  }
  
  async handleUpload(event) {
    const attachment = event.attachment
    const file = attachment.file
    
    if (!file) return
    
    if (this.hasError()) {
      event.preventDefault()
      this.removeAttachment(attachment)
      return
    }
    
    if (!this.isValidFile(file)) {
      event.preventDefault()
      this.removeAttachment(attachment)
      return
    }
    
    this.showProgress(attachment)
    
    try {
      await this.uploadToCloudinary(attachment)
    } catch (error) {
      event.preventDefault()
      this.removeAttachment(attachment)
      this.showError(`Upload failed: ${error.message}`)
    }
  }
  
  isValidFile(file) {
    const validTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    const maxSize = 10 * 1024 * 1024
    return validTypes.includes(file.type) && file.size <= maxSize
  }
  
  removeAttachment(attachment) {
    if (attachment.element && attachment.element.parentNode) {
      attachment.element.remove()
    }
    if (attachment.attachment && attachment.attachment.element) {
      attachment.attachment.element.remove()
    }
    if (attachment.file && attachment.file.name) {
      document.querySelectorAll('[data-trix-attachment]').forEach(el => {
        try {
          const data = JSON.parse(el.dataset.trixAttachment)
          if (data.filename === attachment.file.name) {
            el.remove()
          }
        } catch (e) {}
      })
    }
    if (this.element.editor) {
      try {
        const doc = this.element.editor.getDocument()
        const attachments = doc.attachments
        const found = attachments.find(a => a === attachment.attachment || 
                                             (a.file && a.file.name === attachment.file.name))
        if (found) {
          this.element.editor.deleteAttachment(found)
        }
      } catch (e) {}
    }
    if (attachment.id) {
      const el = document.querySelector(`[data-trix-attachment-id="${attachment.id}"]`)
      if (el) el.remove()
    }
  }
  
  hasError() {
    return document.querySelector('.trix-error-message') !== null
  }
  
  // DISMISS METHOD - Called from the button
  dismissError(event) {
    this.removeError()
    // Also remove any pending attachments
    this.element.removeAttribute('data-error-visible')
  }
  
  showError(message) {
    this.removeError()
    
    const errorDiv = document.createElement("div")
    errorDiv.className = "trix-error-message"
    errorDiv.style.cssText = `
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      background: #ef4444;
      color: white;
      padding: 32px 40px;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.4);
      z-index: 10000;
      max-width: 500px;
      width: 90%;
      text-align: center;
    `
    
    errorDiv.innerHTML = `
      <div style="font-weight: 700; font-size: 20px; margin-bottom: 8px;">Upload Failed</div>
      <div style="font-size: 16px; opacity: 0.95; margin-bottom: 24px;">${message}</div>
      <button class="dismiss-error-btn" 
              style="
                background: rgba(255,255,255,0.2); 
                border: 2px solid rgba(255,255,255,0.3);
                color: white; 
                padding: 10px 32px; 
                border-radius: 8px; 
                cursor: pointer;
                font-size: 16px;
                font-weight: 600;
              ">
        Dismiss
      </button>
    `
    document.body.appendChild(errorDiv)
    
    // Add event listener to the dismiss button
    const dismissBtn = errorDiv.querySelector('.dismiss-error-btn')
    dismissBtn.addEventListener('click', () => {
      this.dismissError()
    })
    
    this.element.setAttribute('data-error-visible', 'true')
  }
  
  removeError() {
    const error = document.querySelector('.trix-error-message')
    if (error) {
      error.remove()
      this.element.removeAttribute('data-error-visible')
    }
  }
  
  // Alternative dismiss method - can be called from anywhere
  dismissError() {
    this.removeError()
    this.element.removeAttribute('data-error-visible')
  }
  
  showProgress(attachment) {
    const progress = document.createElement("div")
    progress.className = "text-sm text-gray-500"
    progress.textContent = "Uploading..."
    attachment.element.appendChild(progress)
  }
  
  async uploadToCloudinary(attachment) {
    const formData = new FormData()
    formData.append("blob", attachment.file)
    
    const response = await fetch("/rails/active_storage/direct_uploads", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: formData
    })
    
    if (!response.ok) {
      throw new Error("Upload to Cloudinary failed")
    }
    
    const blob = await response.json()
    
    attachment.setAttributes({
      sgid: blob.signed_id,
      url: `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`
    })
  }
}
