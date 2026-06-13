import db from './db.js';

/**
 * app.js
 * Frontend Logic & State Controller for Inked (Lit Vibe)
 */

class AppController {
    constructor() {
        // Application State
        this.state = {
            userId: 'u1',
            currentMood: null,
            activeQuotes: [],
            currentQuoteIndex: 0,
            activeBook: null
        };

        // DOM Elements - Views
        this.views = {
            splash: document.getElementById('view-splash'),
            moodSelector: document.getElementById('view-mood-selector'),
            discovery: document.getElementById('view-discovery'),
            library: document.getElementById('view-library'),
            checkout: document.getElementById('view-checkout')
        };

        // DOM Elements - Discovery Deck
        this.cardElement = document.getElementById('active-card');
        this.cardInner = this.cardElement ? this.cardElement.querySelector('.card-inner') : null;
        this.quoteText = this.cardElement ? this.cardElement.querySelector('.quote-text') : null;
        this.bookCover = this.cardElement ? this.cardElement.querySelector('.book-cover') : null;
        this.bookTitle = this.cardElement ? this.cardElement.querySelector('.book-title') : null;
        this.bookAuthor = this.cardElement ? this.cardElement.querySelector('.book-author') : null;
        this.bookRating = this.cardElement ? this.cardElement.querySelector('.book-rating') : null;
        this.bookPages = this.cardElement ? this.cardElement.querySelector('.book-pages') : null;
        this.activeMoodTitle = document.getElementById('active-mood-title');

        // Initialize App
        this.bindEvents();
        this.runSplashSequence();
    }

    // ========================================================================
    // Event Listeners & Binding
    // ========================================================================
    bindEvents() {
        // Mood Selection
        document.querySelectorAll('.mood-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.handleMoodSelection(e.target.dataset.mood));
        });

        // Navigation
        document.getElementById('btn-back-to-moods').addEventListener('click', () => this.switchView('moodSelector'));
        document.getElementById('btn-open-library').addEventListener('click', () => this.openLibrary());
        document.getElementById('btn-back-from-lib').addEventListener('click', () => this.switchView('moodSelector'));
        document.getElementById('btn-open-checkout').addEventListener('click', () => this.switchView('checkout'));
        document.getElementById('btn-back-from-checkout').addEventListener('click', () => this.switchView('library'));

        // Swiping Mechanics
        document.getElementById('btn-swipe-left').addEventListener('click', () => this.handleSwipe('left'));
        document.getElementById('btn-swipe-right').addEventListener('click', () => this.handleSwipe('right'));
        
        // Card Flip
        this.cardElement.addEventListener('click', () => {
            if (this.state.activeQuotes.length > 0) {
                this.cardElement.classList.toggle('flipped');
            }
        });

        // Keyboard Arrow Controls
        document.addEventListener('keydown', (e) => {
            if (this.getCurrentView() === 'discovery') {
                if (e.key === 'ArrowLeft') this.handleSwipe('left');
                if (e.key === 'ArrowRight') this.handleSwipe('right');
            }
        });

        // Checkout Form
        document.getElementById('checkout-form').addEventListener('submit', (e) => this.handleCheckout(e));
    }


    // ========================================================================
    // View Navigation
    // ========================================================================
    switchView(viewName) {
        const targetView = this.views[viewName];
        if (!targetView) return;

        // Fade out current active view
        Object.values(this.views).forEach(view => {
            if (view.classList.contains('active')) {
                view.classList.remove('active');
                // After fade-out transition, hide it
                setTimeout(() => {
                    if (!view.classList.contains('active')) {
                        view.classList.add('hidden');
                    }
                }, 420);
            } else {
                view.classList.add('hidden');
            }
        });

        // Show & fade in target view
        targetView.classList.remove('hidden');
        // Defer adding active so display:flex takes effect first
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                targetView.classList.add('active');
            });
        });
    }

    getCurrentView() {
        for (let [name, element] of Object.entries(this.views)) {
            if (element.classList.contains('active')) return name;
        }
        return null;
    }

    runSplashSequence() {
        setTimeout(() => {
            this.switchView('moodSelector');
        }, 2200);
    }

    // ========================================================================
    // Application Logic
    // ========================================================================
    handleMoodSelection(mood) {
        this.state.currentMood = mood;
        this.activeMoodTitle.textContent = `Discover: ${mood.charAt(0).toUpperCase() + mood.slice(1)}`;
        
        // Execute Database Query!
        // We look up quotes that match the mood. 
        // Note: For demonstration, we query the 'books' collection directly using the mood 
        // to show off the index toggler's effect on performance.
        const result = db.find('books', { mood: mood });
        
        // Map books to their quotes (simulating a $lookup/join for simplicity)
        this.state.activeQuotes = result.results.map(book => {
            // Find a quote for this book
            const quoteResult = db.findOne('quotes', { bookId: book._id });
            return {
                book: book,
                quote: quoteResult.result ? quoteResult.result.text : "A profound thought awaits..."
            };
        });

        this.state.currentQuoteIndex = 0;
        
        if (this.state.activeQuotes.length === 0) {
            this.quoteText.textContent = "No books found for this mood.";
        } else {
            this.loadCardData();
        }

        this.switchView('discovery');
    }

    loadCardData() {
        if (this.state.currentQuoteIndex >= this.state.activeQuotes.length) {
            this.quoteText.textContent = "You've reached the end of this mood!";
            this.cardElement.classList.remove('flipped');
            return;
        }

        const data = this.state.activeQuotes[this.state.currentQuoteIndex];
        const book = data.book;

        // Reset Card State
        this.cardElement.classList.remove('flipped');
        this.cardElement.classList.remove('swipe-left-anim', 'swipe-right-anim');

        // Populate Front
        this.quoteText.textContent = `"${data.quote}"`;

        // Populate Back (Book Reveal)
        this.bookTitle.textContent = book.title;
        this.bookAuthor.textContent = book.author;
        this.bookRating.innerHTML = `<i class="fas fa-star"></i> ${book.rating}`;
        this.bookPages.textContent = `${book.pages} pages`;
        this.bookCover.src = book.coverImageUrl;
    }

    handleSwipe(direction) {
        if (this.state.currentQuoteIndex >= this.state.activeQuotes.length) return;

        const currentData = this.state.activeQuotes[this.state.currentQuoteIndex];
        const bookId = currentData.book._id;

        // Visual Animation
        const animClass = direction === 'left' ? 'swipe-left-anim' : 'swipe-right-anim';
        this.cardElement.classList.add(animClass);

        // Database Update
        if (direction === 'right') {
            // Favorite the book
            db.update('user_preferences', { userId: this.state.userId }, {
                $push: { favoriteBooks: bookId }
            });
        } else {
            // Dismiss the book
            db.update('user_preferences', { userId: this.state.userId }, {
                $push: { dismissedBooks: bookId }
            });
        }

        // Load next card after animation completes
        setTimeout(() => {
            this.state.currentQuoteIndex++;
            this.loadCardData();
        }, 300); // Matches CSS transition duration
    }

    openLibrary() {
        const libContainer = document.getElementById('library-container');
        libContainer.innerHTML = ''; // Clear

        // Execute DB Query: Get User Favorites
        const userPref = db.findOne('user_preferences', { userId: this.state.userId }).result;
        
        if (userPref && userPref.favoriteBooks && userPref.favoriteBooks.length > 0) {
            // Fetch book details for each favorite
            // Simulated $in query
            const favoriteBooks = db.find('books', { _id: { $in: userPref.favoriteBooks } }).results;
            
            favoriteBooks.forEach(book => {
                const item = document.createElement('div');
                item.className = 'lib-item';
                item.innerHTML = `
                    <img src="${book.coverImageUrl}" alt="${book.title}" style="width:100%; border-radius:8px; margin-bottom:0.5rem;">
                    <h4 style="font-size: 0.9rem; margin-bottom: 0.2rem;">${book.title}</h4>
                    <p style="font-size: 0.75rem; color: var(--text-muted);">${book.author}</p>
                `;
                libContainer.appendChild(item);
            });
        } else {
            libContainer.innerHTML = '<p style="color: var(--text-muted); grid-column: 1 / -1; text-align: center;">No favorites yet. Start swiping!</p>';
        }

        this.switchView('library');
    }

    async handleCheckout(e) {
        e.preventDefault();
        const bookstoreId = document.getElementById('bookstore-select').value;
        const artTierId = document.querySelector('input[name="artTier"]:checked').value;
        
        // Reset pipeline UI
        document.querySelectorAll('#transaction-pipeline .step').forEach(step => {
            step.classList.remove('active', 'completed');
            step.classList.add('idle');
        });

        const txSteps = [
            document.getElementById('tx-step-start'),
            document.getElementById('tx-step-update'),
            document.getElementById('tx-step-insert'),
            document.getElementById('tx-step-commit')
        ];

        // Highlight Step 1
        txSteps[0].classList.add('active');

        // We use a small timeout to visually show the steps occurring
        setTimeout(() => {
            txSteps[0].classList.replace('active', 'completed');
            txSteps[1].classList.add('active');
            
            setTimeout(() => {
                txSteps[1].classList.replace('active', 'completed');
                txSteps[2].classList.add('active');
                
                setTimeout(async () => {
                    txSteps[2].classList.replace('active', 'completed');
                    txSteps[3].classList.add('active');
                    
                    // Actually run the DB transaction
                    const success = await db.simulatePurchaseFlow(this.state.userId, 'mockBookId', artTierId, bookstoreId);
                    
                    if (success) {
                        txSteps[3].classList.replace('active', 'completed');
                        alert('Transaction Committed Successfully! Premium Art Unlocked.');
                    } else {
                        txSteps[3].classList.remove('active');
                        txSteps[3].style.color = 'var(--neon-pink)';
                        txSteps[3].textContent = "4. session.abortTransaction() - FAILED";
                    }
                    
                }, 800);
            }, 800);
        }, 800);
    }

}

// Bootstrap Application
document.addEventListener('DOMContentLoaded', () => {
    window.app = new AppController();
});
