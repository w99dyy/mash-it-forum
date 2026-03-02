import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "address", "grid", "status", "badge"]

    async connect() {
        console.log("✅ Wallet controller connected")
        this.setupMetaMaskListeners()
        this.checkPersistedConnection()
    }

    setupMetaMaskListeners() {
        if (!window.ethereum) {
            console.log("❌ MetaMask not detected - skipping listeners")
            return
        }

        console.log("🔧 Setting up MetaMask listeners")

        window.ethereum.removeAllListeners('accountsChanged')
        window.ethereum.removeAllListeners('chainChanged')

        window.ethereum.on('accountsChanged', (accounts) => {
            console.log('🔄 MetaMask accountsChanged event:', accounts)
            const userConnected = localStorage.getItem('userConnected') === 'true'

            if (accounts.length === 0) {
                this.handleMetaMaskDisconnect()
            } else if (userConnected && accounts[0] !== localStorage.getItem('walletAddress')) {
                this.handleAccountSwitch(accounts[0])
            } else if (!userConnected) {
                console.log('⚠️ Ignoring accountsChanged - user not connected via app')
            }
        })

        window.ethereum.on('chainChanged', () => {
            console.log('🔄 MetaMask chainChanged - reloading page')
            window.location.reload()
        })
    }

    checkPersistedConnection() {
        const savedAddress = localStorage.getItem('walletAddress')
        const userConnected = localStorage.getItem('userConnected') === 'true'
        console.log('🔍 Checking persisted connection - savedAddress:', savedAddress, 'userConnected:', userConnected)

        if (savedAddress && userConnected) {
            console.log('✅ Persisted connection found - showing connected')
            this.showConnected(savedAddress)
            if (this.hasGridTarget) {
                this.fetchMashit(savedAddress)
            }
            this.ensureAvatarDiv(savedAddress)
        } else {
            console.log('❌ No persisted connection - showing disconnected')
            this.showDisconnected()
            this.ensureDefaultAvatar()
        }
    }

    async toggle() {
        const isConnected = !!localStorage.getItem('walletAddress') && localStorage.getItem('userConnected') === 'true'
        console.log('🔄 Toggle called - current state:', isConnected ? 'connected' : 'disconnected')

        if (isConnected) {
            await this.disconnectWallet()
        } else {
            await this.connectWallet()
        }
    }

    async connectWallet() {
        console.log('🔗 Starting wallet connect process')
        try {
            this.button.disabled = true
            this.button.textContent = "Connecting..."

            if (!window.ethereum) {
                console.log('❌ MetaMask not installed - opening download page')
                window.open("https://metamask.io/download/")
                throw new Error("Please install MetaMask first")
            }

            console.log('📡 Requesting accounts from MetaMask')
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts"
            })

            if (!accounts || accounts.length === 0) {
                throw new Error("No accounts found")
            }

            const address = accounts[0].toLowerCase()
            console.log("✅ Connected to MetaMask, address:", address)

            // Check availability first
            console.log('🔍 Checking wallet availability with backend...')
            const availabilityResponse = await fetch("/wallet/check_availability", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
                },
                body: JSON.stringify({ wallet_address: address })
            })

            const availabilityData = await availabilityResponse.json()

            if (!availabilityResponse.ok) {
                throw new Error(availabilityData.message || "Wallet is already connected to another account")
            }

            console.log('✅ Wallet available - saving to database...')

            // Save to database
            const connectResponse = await fetch("/wallet/connect", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
                },
                body: JSON.stringify({ wallet_address: address })
            })

            if (!connectResponse.ok) {
                const errorData = await connectResponse.json()
                throw new Error(errorData.error || "Failed to save wallet to database")
            }

            // Store in localStorage (for session management)
            localStorage.setItem('walletAddress', address)
            localStorage.setItem('userConnected', 'true')

            // Update UI
            this.showConnected(address)

            if (this.hasGridTarget) {
                await this.fetchMashit(address)
            }

            // Dispatch event for real-time avatar update
            document.dispatchEvent(new CustomEvent('wallet-connected', { detail: { address } }))

            // Ensure avatar div exists
            this.ensureAvatarDiv(address)

        } catch (error) {
            console.error("❌ Connection error:", error)
            alert(error.message || "Failed to connect wallet")
            this.showDisconnected()
        } finally {
            this.button.disabled = false
        }
    }

    async disconnectWallet() {
        console.log('🔌 Starting wallet disconnect process')
        try {
            this.button.disabled = true
            this.button.textContent = "Disconnecting..."

            // Remove from database
            try {
                await fetch("/wallet/disconnect", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
                    }
                })
            } catch (e) {
                console.log("Backend disconnect failed, continuing with local disconnect")
            }

            // Clear localStorage
            this.clearWalletState()

            // Clear the grid
            this.clearGrid()

            // Update UI
            this.showDisconnected()

            // Revoke MetaMask permissions
            if (window.ethereum) {
                try {
                    await window.ethereum.request({
                        method: 'wallet_revokePermissions',
                        params: [{ eth_accounts: {} }]
                    })
                    console.log("✅ MetaMask permissions revoked")
                } catch (revokeError) {
                    console.log('⚠️ Manual revoke not supported')
                }
            }

            console.log("✅ Disconnect complete")

            // Dispatch event for real-time avatar update
            document.dispatchEvent(new CustomEvent('wallet-disconnected'))

            // Ensure default avatar
            this.ensureDefaultAvatar()

        } catch (error) {
            console.error("❌ Disconnect error:", error)
            this.showDisconnected()
        } finally {
            this.button.disabled = false
        }
    }

    ensureAvatarDiv(address) {
        const avatarContainer = document.querySelector('.w-24.h-24.rounded-full.overflow-hidden.border-4.border-blue-500.bg-gray-100')
        if (avatarContainer) {
            avatarContainer.innerHTML = `
                <div data-controller="mashit-avatar" 
                     data-mashit-avatar-wallet-value="${address}"
                     class="w-full h-full">
                </div>
            `
            console.log('🎨 Avatar div ensured for connected state')
        }
    }

    ensureDefaultAvatar() {
        const avatarContainer = document.querySelector('.w-24.h-24.rounded-full.overflow-hidden.border-4.border-blue-500.bg-gray-100')
        if (avatarContainer) {
            const defaultSrc = avatarContainer.dataset.defaultAvatarSrc || '/assets/mashit.png'
            avatarContainer.innerHTML = `
                <img src="${defaultSrc}" 
                     alt="Default avatar"
                     class="w-full h-full object-cover">
            `
            console.log('🎨 Default avatar ensured for disconnected state')
        }
    }

    clearWalletState() {
        console.log('🧹 Clearing wallet state from localStorage')
        localStorage.removeItem('walletAddress')
        localStorage.removeItem('selectedMASHIT')
        localStorage.removeItem('userConnected')
    }

    handleAccountSwitch(address) {
        console.log('🔄 Account switched to:', address)

        // Update database with new address
        this.syncWalletToDatabase(address)

        localStorage.setItem('walletAddress', address)
        this.showConnected(address)
        if (this.hasGridTarget) {
            this.fetchMashit(address)
        }
        document.dispatchEvent(new CustomEvent('wallet-connected', { detail: { address } }))
        this.ensureAvatarDiv(address)
    }

    async syncWalletToDatabase(address) {
        try {
            await fetch("/wallet/connect", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
                },
                body: JSON.stringify({ wallet_address: address })
            })
        } catch (error) {
            console.error("Failed to sync wallet to database:", error)
        }
    }

    handleMetaMaskDisconnect() {
        console.log("🔴 MetaMask disconnected - clearing app state")
        this.clearWalletState()
        this.showDisconnected()
        this.clearGrid()
        document.dispatchEvent(new CustomEvent('wallet-disconnected'))
        this.ensureDefaultAvatar()
    }

    async fetchMashit(address) {
        if (!this.hasGridTarget) return

        console.log('📡 Fetching mashit for address:', address)
        this.grid.innerHTML = `
            <div class="col-span-full text-center py-8">
                <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                <p class="mt-2 text-gray-600">Loading your mashit...</p>
            </div>
        `

        try {
            const response = await fetch(`https://avatar-artists-guild.web.app/api/mashers/latest?wallet=${address}`)

            if (!response.ok) {
                throw new Error(`HTTP error ${response.status}`)
            }

            const data = await response.json()
            console.log('📦 API response:', data)

            let mashitItems = []
            if (Array.isArray(data)) {
                mashitItems = data
            } else if (data.mashit) {
                mashitItems = data.mashit
            } else if (data.assets) {
                mashitItems = data.assets
            } else {
                mashitItems = [data]
            }

            if (!mashitItems || mashitItems.length === 0) {
                this.grid.innerHTML = `
                    <div class="col-span-full text-center py-8">
                        <p class="text-gray-500">No mashit found for this wallet</p>
                    </div>
                `
                return
            }

            this.renderMashitGrid(mashitItems)

        } catch (error) {
            console.error("❌ Fetch error:", error)
            this.grid.innerHTML = `
                <div class="col-span-full text-center py-8">
                    <p class="text-red-600 mb-2">Failed to load mashit</p>
                    <p class="text-sm text-gray-500 mb-4">${error.message}</p>
                    <button data-action="click->wallet#retryFetch" 
                            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                        Try Again
                    </button>
                </div>
            `
        }
    }

    renderMashitGrid(items) {
        const gridHTML = items.map(item => {
            const imageUrl = item.image_url || item.image || '/placeholder.png'
            const name = item.name || 'Unnamed Mashit'

            return `
                <div class="cursor-pointer hover:scale-105 transition-transform duration-200"
                     data-action="click->wallet#select"
                     data-mashit='${JSON.stringify(item).replace(/'/g, "&apos;")}'>
                    <div class="aspect-square rounded-lg overflow-hidden border-2 border-gray-200 hover:border-blue-500 bg-gray-100">
                        <img src="${imageUrl}" 
                             alt="${name}"
                             class="w-full h-full object-cover"
                             loading="lazy"
                             onerror="this.src='/placeholder.png'">
                    </div>
                    <p class="mt-2 text-sm font-medium text-center truncate">${name}</p>
                </div>
            `
        }).join('')

        this.grid.innerHTML = gridHTML
    }

    retryFetch() {
        const address = localStorage.getItem('walletAddress')
        if (address) {
            this.fetchMashit(address)
        }
    }

    select(event) {
        const mashit = JSON.parse(event.currentTarget.dataset.mashit)

        document.querySelectorAll('[data-action="click->wallet#select"]').forEach(el => {
            el.classList.remove('selected')
            const img = el.querySelector('img')
            if (img) {
                img.classList.remove('border-blue-500', 'border-2')
            }
        })

        event.currentTarget.classList.add('selected')
        const selectedImg = event.currentTarget.querySelector('img')
        if (selectedImg) {
            selectedImg.classList.add('border-blue-500', 'border-2')
        }

        localStorage.setItem('selectedMASHIT', JSON.stringify(mashit))

        const avatarImg = document.querySelector('.user-avatar')
        if (avatarImg) {
            avatarImg.src = mashit.image_url || mashit.image || '/placeholder.png'
        }
    }

    showConnected(address) {
        console.log('🎨 Showing connected state for address:', address)

        this.button.textContent = "Disconnect"
        this.button.classList.remove('bg-blue-600', 'hover:bg-blue-700')
        this.button.classList.add('bg-red-600', 'hover:bg-red-700')

        if (this.hasAddressTarget) {
            this.addressTarget.textContent = `${address.slice(0, 6)}...${address.slice(-4)}`
            this.addressTarget.classList.remove('hidden')
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "Connected"
        }

        if (this.hasBadgeTarget) {
            this.badgeTarget.className = "inline-flex items-center px-2 py-1 bg-green-100 text-green-800 text-sm rounded"
            this.badgeTarget.innerHTML = `
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                ${address.slice(0, 6)}...${address.slice(-4)}
            `
        }
    }

    showDisconnected() {
        console.log('🎨 Showing disconnected state')

        this.button.textContent = "Connect Wallet"
        this.button.classList.remove('bg-red-600', 'hover:bg-red-700')
        this.button.classList.add('bg-blue-600', 'hover:bg-blue-700')

        if (this.hasAddressTarget) {
            this.addressTarget.textContent = ""
            this.addressTarget.classList.add('hidden')
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "Not connected"
        }

        if (this.hasBadgeTarget) {
            this.badgeTarget.className = "inline-flex items-center px-2 py-1 text-gray-600 text-sm rounded"
            this.badgeTarget.innerHTML = `
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path>
                </svg>
                No Wallet Connected
            `
        }
    }

    clearGrid() {
        if (this.hasGridTarget) {
            this.grid.innerHTML = `
                <div class="col-span-full text-center py-8 text-gray-500">
                    Connect your wallet to see your mashit
                </div>
            `
        }
    }

    get button() { return this.buttonTarget }
    get address() { return this.addressTarget }
    get grid() { return this.gridTarget }
    get status() { return this.statusTarget }
    get badge() { return this.badgeTarget }
}