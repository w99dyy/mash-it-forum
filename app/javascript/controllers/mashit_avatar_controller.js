import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        console.log("✅ Mashit avatar controller connected")

        // Check initial connection state on load (read-only from localStorage)
        this.checkInitialState()

        // Listen for wallet connection events from wallet_controller
        document.addEventListener('wallet-connected', this.handleWalletConnected.bind(this))
        document.addEventListener('wallet-disconnected', this.handleWalletDisconnected.bind(this))
    }

    disconnect() {
        // Clean up event listeners
        document.removeEventListener('wallet-connected', this.handleWalletConnected.bind(this))
        document.removeEventListener('wallet-disconnected', this.handleWalletDisconnected.bind(this))
    }

    checkInitialState() {
        const savedAddress = localStorage.getItem('walletAddress')
        const userConnected = localStorage.getItem('userConnected') === 'true'

        if (savedAddress && userConnected) {
            console.log('🔍 Initial state: Wallet connected - fetching avatar for', savedAddress)
            this.fetchMashit(savedAddress)
        } else {
            console.log('🔍 Initial state: Wallet not connected - showing default avatar')
            this.showDefault()
        }
    }

    handleWalletConnected(event) {
        const address = event.detail.address
        console.log('🔗 Wallet connected event received - fetching avatar for', address)
        this.fetchMashit(address)
    }

    handleWalletDisconnected() {
        console.log('🔌 Wallet disconnected event received - showing default avatar')
        this.showDefault()
    }

    async fetchMashit(walletAddress) {
        try {
            // Show loading state with the base color as background
            this.element.innerHTML = `
        <div class="w-full h-full flex items-center justify-center" style="background-color: #EFEFE2;">
          <div class="w-6 h-6 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin"></div>
        </div>
      `

            const response = await fetch(`https://avatar-artists-guild.web.app/api/mashers/latest?wallet=${walletAddress}`)

            if (!response.ok) throw new Error(`HTTP ${response.status}`)

            const data = await response.json()
            console.log("Mashit data:", data)

            // Get base color from the response
            const baseColor = data.colors?.base || '#EFEFE2'
            console.log("Base color:", baseColor)

            const assets = data.assets || []

            if (assets.length === 0) {
                console.warn("No assets found")
                this.showDefault()
                return
            }

            // Sort assets
            const sortedAssets = this.sortAssets(assets)

            // Render with base color
            this.renderLayers(sortedAssets, baseColor)

        } catch (error) {
            console.error("Failed to load mashit:", error)
            this.showDefault()
        }
    }

    sortAssets(assets) {
        const layerOrder = [
            'background',
            'hair_back',
            'cape',
            'bottom',
            'upper',
            'head',
            'eyes',
            'hair_front',
            'hat',
            'left_accessory',
            'right_accessory'
        ]

        return [...assets].sort((a, b) => {
            const indexA = layerOrder.indexOf(a.name)
            const indexB = layerOrder.indexOf(b.name)

            if (indexA === -1) return 1
            if (indexB === -1) return -1
            return indexA - indexB
        })
    }

    renderLayers(assets, baseColor) {
        // Clear container
        this.element.innerHTML = ''

        // Create container with base color
        const container = document.createElement('div')
        container.className = 'relative w-full h-full'
        container.style.backgroundColor = baseColor
        container.style.position = 'relative'
        container.style.width = '100%'
        container.style.height = '100%'

        // Track loaded images to know when all are done
        let loadedCount = 0
        const totalImages = assets.length

        // Add each asset as a layer
        assets.forEach((asset, index) => {
            if (!asset.image) {
                loadedCount++
                return
            }

            const img = document.createElement('img')
            img.src = asset.image
            img.alt = asset.name || 'Layer'

            // Critical styling for layering
            img.style.position = 'absolute'
            img.style.top = '0'
            img.style.left = '0'
            img.style.width = '100%'
            img.style.height = '100%'
            img.style.objectFit = 'contain'
            img.style.zIndex = index + 1
            img.style.pointerEvents = 'none'

            // Add loading attribute for performance
            img.loading = 'lazy'

            // Handle successful load
            img.onload = () => {
                loadedCount++
                console.log(`✅ Loaded: ${asset.name}`)
            }

            // Handle load errors
            img.onerror = (e) => {
                loadedCount++
                console.warn(`❌ Failed to load: ${asset.name} - ${asset.image}`)
                e.target.style.display = 'none'
            }

            container.appendChild(img)
        })

        this.element.appendChild(container)

        // If no images loaded, show default after timeout
        setTimeout(() => {
            if (loadedCount === 0) {
                console.warn("No images loaded after 3 seconds")
                this.showDefault()
            }
        }, 3000)
    }

    showDefault() {
        this.element.innerHTML = `<img src="${window.assetPaths.mashit}" alt="Default avatar" class="w-full h-full object-cover">`;
    }
}