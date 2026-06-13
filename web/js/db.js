/**
 * db.js
 * Simulated MongoDB Engine for Inked (Lit Vibe) Web Application
 * 
 * This module simulates a MongoDB backend entirely in the browser. 
 * It includes a query engine, indexing simulator, performance metrics logger,
 * and a multi-document ACID transaction simulator.
 */

class MockMongoDB {
    constructor() {
        this.collections = {
            users: [],
            books: [],
            quotes: [],
            bookstores: [],
            user_preferences: [],
            transactions: []
        };

        // Track active indexes for collections
        this.indexes = {
            users: { email: true },
            books: { mood: false, _id: true },
            quotes: { mood: false, bookId: false },
            bookstores: { location: false },
            user_preferences: { userId: true }
        };

        this.transactionSession = null;
        this.queryLogs = []; // Stores logs of executed queries for the UI
        
        if (!this._loadFromStorage()) {
            this._initializeData();
        }
    }

    /**
     * Initializes the database with mock data.
     */
    _initializeData() {
        // Mock Books
        this.collections.books = [
            { _id: 'b1', title: 'The Silent Patient', author: 'Alex Michaelides', mood: 'thrilled', rating: 4.5, pages: 336, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=Silent+Patient' },
            { _id: 'b2', title: 'Norwegian Wood', author: 'Haruki Murakami', mood: 'melancholic', rating: 4.0, pages: 296, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=Norwegian+Wood' },
            { _id: 'b3', title: 'Pride and Prejudice', author: 'Jane Austen', mood: 'romantic', rating: 4.8, pages: 432, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=Pride+and+Prejudice' },
            { _id: 'b4', title: 'Siddhartha', author: 'Hermann Hesse', mood: 'thoughtful', rating: 4.6, pages: 152, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=Siddhartha' },
            { _id: 'b5', title: 'The Hobbit', author: 'J.R.R. Tolkien', mood: 'adventurous', rating: 4.9, pages: 310, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=The+Hobbit' },
            { _id: 'b6', title: 'A Man Called Ove', author: 'Fredrik Backman', mood: 'happy', rating: 4.7, pages: 337, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=A+Man+Called+Ove' },
            { _id: 'b7', title: 'The Bell Jar', author: 'Sylvia Plath', mood: 'sad', rating: 4.2, pages: 244, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=The+Bell+Jar' },
            { _id: 'b8', title: 'Meditations', author: 'Marcus Aurelius', mood: 'peaceful', rating: 4.8, pages: 254, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA?text=Meditations' }
        ];
        
        // Let's add more books to make searches noticeable
        for (let i = 9; i <= 200; i++) {
            const moods = ['happy', 'sad', 'peaceful', 'thrilled', 'thoughtful', 'adventurous', 'melancholic', 'romantic', 'mysterious', 'inspiring', 'nostalgic', 'anxious'];
            const randomMood = moods[Math.floor(Math.random() * moods.length)];
            this.collections.books.push({
                _id: `b${i}`, title: `Mock Book ${i}`, author: `Author ${i}`, mood: randomMood, rating: 4.0, pages: 300, coverImageUrl: 'https://via.placeholder.com/300x450/1A0A2E/AB63FA'
            });
        }

        // Mock Quotes
        this.collections.quotes = [
            { _id: 'q1', text: 'You can never get a cup of tea large enough or a book long enough to suit me.', bookId: 'b5', mood: 'peaceful' },
            { _id: 'q2', text: 'What are men to rocks and mountains?', bookId: 'b3', mood: 'romantic' },
            { _id: 'q3', text: 'If you only read the books that everyone else is reading, you can only think what everyone else is thinking.', bookId: 'b2', mood: 'thoughtful' },
            { _id: 'q4', text: 'There is some good in this world, and it’s worth fighting for.', bookId: 'b5', mood: 'adventurous' },
        ];

        // Add dummy quotes
        for(let i=5; i<=200; i++) {
            const moods = ['happy', 'sad', 'peaceful', 'thrilled', 'thoughtful', 'adventurous', 'melancholic', 'romantic', 'mysterious', 'inspiring', 'nostalgic', 'anxious'];
            const randomMood = moods[Math.floor(Math.random() * moods.length)];
            this.collections.quotes.push({
                _id: `q${i}`, text: `This is a profound quote ${i} that touches the soul.`, bookId: `b${Math.floor(Math.random()*200)+1}`, mood: randomMood
            });
        }

        // Mock Bookstores
        this.collections.bookstores = [
            { _id: 's1', name: 'Saeed Book Bank', location: 'Islamabad', hasPremiumArt: true },
            { _id: 's2', name: 'Readings', location: 'Lahore', hasPremiumArt: true },
            { _id: 's3', name: 'Liberty Books', location: 'Karachi', hasPremiumArt: false }
        ];

        // Mock User Preferences (for the default mock user if needed, though real users will be created via Auth)
        this.collections.users = [
            { _id: 'u1', username: 'Guest Reader', email: 'guest@litvibe.com', password: 'password123' }
        ];
        this.collections.user_preferences = [
            { userId: 'u1', favoriteBooks: [], readBooks: [], toReadBooks: [], dismissedBooks: [], moodFrequency: {}, lastUpdated: new Date() }
        ];
        
        this._saveToStorage();
    }

    /**
     * Data Persistence Simulation
     */
    _saveToStorage() {
        if (typeof window !== 'undefined') {
            localStorage.setItem('inked_db_snapshot', JSON.stringify(this.collections));
        }
    }

    _loadFromStorage() {
        if (typeof window !== 'undefined') {
            const data = localStorage.getItem('inked_db_snapshot');
            if (data) {
                this.collections = JSON.parse(data);
                return true;
            }
        }
        return false;
    }

    /**
     * Indexing Simulator
     */
    toggleIndex(collectionName, field) {
        if (!this.indexes[collectionName]) return;
        this.indexes[collectionName][field] = !this.indexes[collectionName][field];
        this._logToConsole(`System: Index on ${collectionName}.${field} set to ${this.indexes[collectionName][field] ? 'ON' : 'OFF'}`);
        return this.indexes[collectionName][field];
    }

    /**
     * Logs the query to our internal console for the UI to display.
     */
    _logToConsole(message, details = null) {
        const logEntry = {
            timestamp: new Date(),
            message,
            details
        };
        this.queryLogs.unshift(logEntry);
        console.log(message, details || '');
        
        // Dispatch custom event for UI updates
        if (typeof window !== 'undefined') {
            window.dispatchEvent(new CustomEvent('dbLogEvent', { detail: logEntry }));
        }
    }

    /**
     * Core Query Parser & Execution Simulator
     */
    find(collectionName, query) {
        const startTime = performance.now();
        const collection = this.collections[collectionName];
        
        if (!collection) throw new Error(`Collection ${collectionName} not found`);

        let executionStrategy = 'COLLSCAN';
        let docsExamined = 0;
        let results = [];

        // Check if we can use an index based on the query fields
        const queryFields = Object.keys(query);
        let usedIndexField = null;

        for (let field of queryFields) {
            if (this.indexes[collectionName] && this.indexes[collectionName][field]) {
                executionStrategy = 'IXSCAN';
                usedIndexField = field;
                break;
            }
        }

        // Simulate query execution
        if (executionStrategy === 'IXSCAN') {
            // Simulated IXSCAN: Fast. O(log N) lookup.
            docsExamined = 0; // In a perfect B-Tree index, we examine much fewer.
            // Simulate index search overhead (very low)
            const simulatedIndexDelay = Math.random() * 2; // 0-2ms
            
            // Filter results
            results = collection.filter(doc => {
                docsExamined++; // Examining only matched/close index nodes in theory, but we'll count filtered docs.
                return this._matchQuery(doc, query);
            });
            
            // Simulate index speed
            this._sleep(simulatedIndexDelay); 

        } else {
            // Simulated COLLSCAN: Slow. O(N) lookup.
            // We must scan the entire collection.
            for (let doc of collection) {
                docsExamined++;
                if (this._matchQuery(doc, query)) {
                    results.push(doc);
                }
            }
            
            // Simulate collection scan overhead (slower based on collection size)
            // A real DB would be faster for 200 items, but we exaggerate for educational purposes
            const simulatedScanDelay = (collection.length * 0.5) + (Math.random() * 20); // ~100ms+ delay
            this._sleep(simulatedScanDelay);
        }

        const endTime = performance.now();
        const executionTimeMs = (endTime - startTime).toFixed(2);

        // Build explain plan
        const explainPlan = {
            query: query,
            collection: collectionName,
            executionStats: {
                executionStrategy,
                indexUsed: usedIndexField,
                executionTimeMillis: executionTimeMs,
                totalDocsExamined: executionStrategy === 'IXSCAN' ? results.length : collection.length,
                nReturned: results.length
            }
        };

        this._logToConsole(`db.${collectionName}.find(${JSON.stringify(query)})`, explainPlan);

        return {
            results,
            explain: () => explainPlan
        };
    }

    findOne(collectionName, query) {
        const res = this.find(collectionName, query);
        return {
            result: res.results.length > 0 ? res.results[0] : null,
            explain: res.explain
        };
    }

    update(collectionName, query, updateObj) {
        this._logToConsole(`db.${collectionName}.update(${JSON.stringify(query)}, ${JSON.stringify(updateObj)})`);
        let count = 0;
        this.collections[collectionName] = this.collections[collectionName].map(doc => {
            if (this._matchQuery(doc, query)) {
                count++;
                return this._applyUpdate(doc, updateObj);
            }
            return doc;
        });
        if (count > 0) this._saveToStorage();
        return { modifiedCount: count };
    }

    insert(collectionName, document) {
        this._logToConsole(`db.${collectionName}.insert(${JSON.stringify(document)})`);
        const newDoc = { ...document, _id: `id_${Date.now()}_${Math.floor(Math.random()*1000)}` };
        this.collections[collectionName].push(newDoc);
        this._saveToStorage();
        return { insertedId: newDoc._id };
    }

    /**
     * Helper to match queries like { mood: 'sad', rating: { $gte: 4 } }
     */
    _matchQuery(doc, query) {
        for (let key in query) {
            const queryValue = query[key];
            if (typeof queryValue === 'object' && queryValue !== null) {
                // Handle operators like $gte, $in
                if (queryValue.$gte !== undefined && !(doc[key] >= queryValue.$gte)) return false;
                if (queryValue.$in !== undefined && !queryValue.$in.includes(doc[key])) return false;
            } else {
                if (doc[key] !== queryValue) return false;
            }
        }
        return true;
    }

    /**
     * Helper to apply updates like { $set: { ... }, $push: { ... } }
     */
    _applyUpdate(doc, updateObj) {
        let updatedDoc = { ...doc };
        if (updateObj.$set) {
            updatedDoc = { ...updatedDoc, ...updateObj.$set };
        }
        if (updateObj.$push) {
            for (let key in updateObj.$push) {
                if (!Array.isArray(updatedDoc[key])) updatedDoc[key] = [];
                updatedDoc[key].push(updateObj.$push[key]);
            }
        }
        return updatedDoc;
    }

    /**
     * Helper to artificially delay execution (blocking for simulation)
     */
    _sleep(ms) {
        const start = performance.now();
        while (performance.now() - start < ms) {
            // Block thread to simulate DB work
        }
    }

    /**
     * ACID Transaction Simulator
     */
    startTransaction() {
        if (this.transactionSession) {
            throw new Error("Transaction already in progress.");
        }
        this._logToConsole(`session.startTransaction() - Initializing Multi-Document Transaction`);
        
        // Deep copy collections to allow rollback
        this.transactionSession = {
            snapshot: JSON.parse(JSON.stringify(this.collections)),
            logs: []
        };
    }

    commitTransaction() {
        if (!this.transactionSession) {
            throw new Error("No transaction in progress.");
        }
        this._logToConsole(`session.commitTransaction() - Writing locks released, changes committed.`);
        this.transactionSession = null; // Clear snapshot, keeping changes
        return { ok: 1 };
    }

    abortTransaction() {
        if (!this.transactionSession) {
            throw new Error("No transaction in progress.");
        }
        this._logToConsole(`session.abortTransaction() - Rolling back changes to snapshot.`);
        // Restore collections from snapshot
        this.collections = this.transactionSession.snapshot;
        this.transactionSession = null;
        return { ok: 1 };
    }

    /**
     * High-level simulation of buying a book or premium art.
     * Demonstrates a transaction visually.
     */
    async simulatePurchaseFlow(userId, bookId, artTierId, bookstoreId) {
        this.startTransaction();

        try {
            this._logToConsole(`System: Processing purchase for User ${userId}`);
            
            // 1. Verify user exists
            const user = this.findOne('user_preferences', { userId }).result;
            if (!user) throw new Error("User not found");

            // 2. Insert transaction record
            this.insert('transactions', {
                userId,
                bookId,
                artTierId,
                bookstoreId,
                status: 'pending',
                date: new Date()
            });

            // 3. Update user preferences to unlock premium art
            this.update('user_preferences', { userId }, {
                $push: { premiumUnlocked: artTierId }
            });

            // 4. Update transaction to completed
            this.update('transactions', { userId, status: 'pending' }, {
                $set: { status: 'completed' }
            });

            // Commit the transaction
            this.commitTransaction();
            
            this._logToConsole(`System: Purchase successful and committed.`);
            return true;
        } catch (error) {
            this._logToConsole(`System: Error in purchase flow - ${error.message}`);
            this.abortTransaction();
            return false;
        }
    }

    /**
     * Auth Flow Simulation
     */
    registerUser(username, email, password) {
        const existing = this.findOne('users', { email }).result;
        if (existing) throw new Error("Email already registered");

        const userRes = this.insert('users', { username, email, password });
        const userId = userRes.insertedId;

        // Create default preferences
        this.insert('user_preferences', {
            userId: userId,
            favoriteBooks: [],
            readBooks: [],
            toReadBooks: [],
            dismissedBooks: [],
            moodFrequency: {},
            lastUpdated: new Date()
        });

        return { userId, username, email };
    }

    loginUser(email, password) {
        const user = this.findOne('users', { email }).result;
        if (!user || user.password !== password) {
            throw new Error("Invalid email or password");
        }
        return { userId: user._id, username: user.username, email: user.email };
    }
}

// Export a singleton instance for the app to use
const db = new MockMongoDB();
export default db;
