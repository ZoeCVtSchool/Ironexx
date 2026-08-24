// Ironexx PWA TV - Main Application Logic
const API_BASE = 'http://localhost:3000/api';

let currentFocusIndex = 0;
let machines = [];
let activeBranch = null;
let branches = [
    { id: 1, nombre: 'Sucursal Centro', activa: 1 },
    { id: 2, nombre: 'Sucursal Norte', activa: 1 },
    { id: 3, nombre: 'Sucursal Sur', activa: 1 }
];
const localMachineStorageKey = 'local_registered_machines';

const dummyProductsByBranch = {
    1: [
        { id: 101, nombre: 'Excavadora CAT 320', descripcion: 'Equipo de excavación para obra civil.', precio: 3200000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EEXCAVADORA%3C/text%3E%3C/svg%3E', cantidad: 4, estado: 'disponible' },
        { id: 102, nombre: 'Retroexcavadora', descripcion: 'Ideal para trabajos de tierra y nivelación.', precio: 1850000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23111c2e"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ERETRO%3C/text%3E%3C/svg%3E', cantidad: 7, estado: 'disponible' },
        { id: 103, nombre: 'Montacargas', descripcion: 'Movilización interna de materiales y cargas.', precio: 950000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23171f2f"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EMONTACARGAS%3C/text%3E%3C/svg%3E', cantidad: 3, estado: 'disponible' },
        { id: 104, nombre: 'Compactador', descripcion: 'Equipo para compactación y preparación de terreno.', precio: 700000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ECOMPACTADOR%3C/text%3E%3C/svg%3E', cantidad: 6, estado: 'disponible' }
    ],
    2: [
        { id: 201, nombre: 'Bulldozer D6', descripcion: 'Tractor de orugas para movimiento de tierra.', precio: 4100000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EBULLDOZER%3C/text%3E%3C/svg%3E', cantidad: 2, estado: 'disponible' },
        { id: 202, nombre: 'Grúa móvil', descripcion: 'Carga y maniobra para materiales pesados.', precio: 5200000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23111c2e"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EGRUA%3C/text%3E%3C/svg%3E', cantidad: 5, estado: 'disponible' },
        { id: 203, nombre: 'Pala cargadora', descripcion: 'Optimiza movimiento de materiales en obra.', precio: 2750000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23171f2f"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EPALA%3C/text%3E%3C/svg%3E', cantidad: 8, estado: 'disponible' },
        { id: 204, nombre: 'Cortadora', descripcion: 'Herramienta para corte rápido y preciso.', precio: 380000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ECORTADORA%3C/text%3E%3C/svg%3E', cantidad: 12, estado: 'disponible' }
    ],
    3: [
        { id: 301, nombre: 'Camión de volteo', descripcion: 'Transporte de materiales a grandes distancias.', precio: 5800000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ECAMION%3C/text%3E%3C/svg%3E', cantidad: 3, estado: 'disponible' },
        { id: 302, nombre: 'Soldadora', descripcion: 'Equipo de corte y soldadura industrial.', precio: 420000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23111c2e"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ESOLEDADORA%3C/text%3E%3C/svg%3E', cantidad: 9, estado: 'disponible' },
        { id: 303, nombre: 'Martillo demoledor', descripcion: 'Herramienta para demolición y demolición selectiva.', precio: 330000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%23171f2f"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3EMARTILLO%3C/text%3E%3C/svg%3E', cantidad: 7, estado: 'disponible' },
        { id: 304, nombre: 'Taladro perforador', descripcion: 'Equipo para perforación y perforado pesado.', precio: 290000, imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="72" fill="%23d4af62" font-family="Arial"%3ETALADRO%3C/text%3E%3C/svg%3E', cantidad: 14, estado: 'disponible' }
    ]
};

const channel = new BroadcastChannel('ironexx-ecosystem');

channel.onmessage = (event) => {
    const { type, data } = event.data || {};

    if (type === 'MACHINE_SELECTED') {
        updateMachineSelection(data.machineId);
    } else if (type === 'BRANCH_CHANGED') {
        updateBranchDisplay(data.branch);
    } else if (type === 'NEW_MACHINE_REGISTERED') {
        appendRegisteredMachine(data);
    }
};

function readLocalRegisteredMachines() {
    try {
        const saved = JSON.parse(localStorage.getItem(localMachineStorageKey) || '[]');
        return Array.isArray(saved) ? saved : [];
    } catch (_) {
        return [];
    }
}

function saveLocalRegisteredMachines(items) {
    localStorage.setItem(localMachineStorageKey, JSON.stringify(items));
}

async function fetchRemoteRegisteredMachines() {
    try {
        const response = await fetch(`${API_BASE}/machines`);
        if (!response.ok) {
            return [];
        }

        const payload = await response.json();
        const rows = Array.isArray(payload?.data) ? payload.data : [];
        return rows.map((item) => ({
            id: item.id || Date.now() + Math.random(),
            nombre: item.nombre || 'Máquina',
            codigo: item.codigo || `QR-${Date.now()}`,
            sucursal: item.sucursal || 'Sucursal Centro',
            descripcion: item.descripcion || 'Máquina registrada por QR',
            estado: item.estado || 'Activo',
            modelo: item.modelo || 'Sin modelo',
            tipo: item.tipo || 'maquinaria',
            precio: item.precio || 0,
            source: 'remote'
        }));
    } catch (_) {
        return [];
    }
}

function appendRegisteredMachine(machine) {
    if (!machine || !machine.nombre || !machine.sucursal) {
        return;
    }

    const saved = readLocalRegisteredMachines();
    const exists = saved.some((item) => item.codigo === machine.codigo || item.nombre === machine.nombre);
    if (!exists) {
        saved.unshift({
            id: Date.now(),
            nombre: machine.nombre,
            codigo: machine.codigo || `QR-${Date.now()}`,
            sucursal: machine.sucursal,
            descripcion: machine.descripcion || 'Máquina registrada por QR',
            estado: machine.estado || 'Activo',
            modelo: machine.modelo || 'Sin modelo',
            tipo: machine.tipo || 'maquinaria',
            precio: machine.precio || 0,
            source: 'registered'
        });
        saveLocalRegisteredMachines(saved);
    }

    const branchId = branches.findIndex((branch) => branch.nombre === machine.sucursal) + 1;
    const branchKey = branchId > 0 ? branchId : activeBranch?.id || 1;
    const branchName = branches.find((branch) => Number(branch.id) === Number(branchKey))?.nombre || machine.sucursal;
    const machineEntry = buildMachineFromProduct({
        id: machine.id || Date.now(),
        nombre: machine.nombre,
        descripcion: machine.descripcion || 'Máquina registrada por QR',
        precio: machine.precio || 0,
        cantidad: 1,
        estado: machine.estado || 'disponible',
        imagen_url: 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="60" fill="%23d4af62" font-family="Arial"%3E${encodeURIComponent(machine.nombre)}%3C/text%3E%3C/svg%3E'
    }, branchName);

    const list = [...machines, machineEntry].filter((entry, index, arr) => arr.findIndex((item) => item.id === entry.id) === index);
    machines = list;
    renderMachineGrid();
    updateBackgroundMedia(machineEntry);
    updateBranchDisplay(branchName);
}

document.addEventListener('DOMContentLoaded', () => {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('./service-worker.js')
            .then(reg => console.log('SW registrado:', reg))
            .catch(err => console.error('SW error:', err));
    }

    initializeDateTime();
    loadMachinery();
    setupKeyboardNavigation();
    setInterval(async () => {
        if (!activeBranch) {
            return;
        }
        await loadBranchProducts(activeBranch.id, activeBranch.nombre);
    }, 4000);
});

function initializeDateTime() {
    const updateDateTime = () => {
        const now = new Date();
        const options = {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        };
        document.getElementById('datetime').textContent = now.toLocaleDateString('es-ES', options);
    };

    updateDateTime();
    setInterval(updateDateTime, 1000);
}

async function getBranches() {
    return branches;
}

async function getProductsByBranch(branchId) {
    return dummyProductsByBranch[branchId] || [];
}

function toCurrency(amount) {
    const value = Number(amount || 0);
    return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN',
        maximumFractionDigits: 0,
    }).format(value);
}

function buildMachineFromProduct(product, branchName) {
    const details = [
        product.descripcion ? `Descripción: ${product.descripcion}` : 'Sin descripción',
        `Precio: ${toCurrency(product.precio)}`,
        `Cantidad: ${product.cantidad ?? 0}`,
        `Estado: ${product.estado ?? 'disponible'}`,
    ];

    return {
        id: Number(product.id),
        name: product.nombre || 'Producto',
        price: toCurrency(product.precio),
        branch: branchName || 'Sucursal central',
        details,
        video: null,
        image: product.imagen_url || 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect fill="%231a1a2e" width="1920" height="1080"/%3E%3Ctext x="960" y="540" font-size="80" fill="%23d4af62" text-anchor="middle"%3EIRONEXX%3C/text%3E%3C/svg%3E',
    };
}

async function loadMachinery() {
    const loadingScreen = document.getElementById('loadingScreen');

    try {
        branches = await getBranches();
        const selectedBranch = branches[0] || { id: 1, nombre: 'Sucursal central' };
        activeBranch = selectedBranch;
        populateBranchOptions();
        await loadBranchProducts(selectedBranch.id, selectedBranch.nombre);
        loadingScreen.classList.add('hidden');
    } catch (error) {
        console.error('Error loading machinery:', error);
        loadingScreen.innerHTML = '<p>Error al cargar datos de prueba. Intenta de nuevo.</p>';
    }
}

function populateBranchOptions() {
    const select = document.getElementById('branchSelect');
    if (!select) return;

    select.innerHTML = '';

    branches.forEach((branch) => {
        const option = document.createElement('option');
        option.value = String(branch.id);
        option.textContent = branch.nombre || 'Sucursal';
        if (activeBranch && Number(branch.id) === Number(activeBranch.id)) {
            option.selected = true;
        }
        select.appendChild(option);
    });

    select.onchange = async (event) => {
        const selectedId = Number(event.target.value);
        const selectedBranch = branches.find((branch) => Number(branch.id) === selectedId) || { id: selectedId, nombre: 'Sucursal' };
        activeBranch = selectedBranch;
        await loadBranchProducts(selectedBranch.id, selectedBranch.nombre);
    };
}

async function loadBranchProducts(branchId, branchName) {
    const products = await getProductsByBranch(branchId);
    const remoteMachines = await fetchRemoteRegisteredMachines();
    const localMachines = readLocalRegisteredMachines()
        .filter((item) => item.sucursal === branchName)
        .map((item) => buildMachineFromProduct({
            id: item.id || Date.now(),
            nombre: item.nombre,
            descripcion: item.descripcion || 'Máquina registrada por QR',
            precio: item.precio || 0,
            cantidad: 1,
            estado: item.estado || 'disponible',
            imagen_url: `data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="60" fill="%23d4af62" font-family="Arial"%3E${encodeURIComponent(item.nombre || 'MÁQUINA')}%3C/text%3E%3C/svg%3E`
        }, branchName));
    const remoteBranchMachines = remoteMachines
        .filter((item) => item.sucursal === branchName)
        .map((item) => buildMachineFromProduct({
            id: item.id || Date.now(),
            nombre: item.nombre,
            descripcion: item.descripcion || 'Máquina registrada por QR',
            precio: item.precio || 0,
            cantidad: 1,
            estado: item.estado || 'disponible',
            imagen_url: `data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"%3E%3Crect width="100%" height="100%" fill="%230b1220"/%3E%3Ctext x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="60" fill="%23d4af62" font-family="Arial"%3E${encodeURIComponent(item.nombre || 'MÁQUINA')}%3C/text%3E%3C/svg%3E`
        }, branchName));

    const merged = [...products.map(product => buildMachineFromProduct(product, branchName)), ...localMachines, ...remoteBranchMachines];
    const uniqueById = new Map();
    merged.forEach((machine) => {
        if (!uniqueById.has(String(machine.id))) {
            uniqueById.set(String(machine.id), machine);
        }
    });

    machines = Array.from(uniqueById.values());
    renderMachineGrid();

    if (machines.length > 0) {
        updateBackgroundMedia(machines[0]);
    }

    updateBranchDisplay(branchName);
}

function renderMachineGrid() {
    const grid = document.getElementById('machineGrid');
    grid.innerHTML = '';

    machines.forEach((machine, index) => {
        const card = createMachineCard(machine, index);
        grid.appendChild(card);
    });

    if (grid.children.length > 0) {
        grid.children[0].focus();
    }
}

function createMachineCard(machine, index) {
    const card = document.createElement('div');
    card.className = 'machine-card';
    card.tabIndex = 0;
    card.dataset.index = index;
    card.dataset.machineId = machine.id;

    card.innerHTML = `
        <div class="machine-card-header">
            <h2 class="machine-name">${machine.name}</h2>
            <span class="machine-price">${machine.price}</span>
        </div>
        <div class="machine-details">
            ${machine.details.map(detail => `<div class="machine-detail">${detail}</div>`).join('')}
        </div>
        <div class="machine-branch">📍 ${machine.branch}</div>
    `;

    card.addEventListener('keydown', handleCardKeydown);
    card.addEventListener('click', () => selectMachine(machine));

    return card;
}

function setupKeyboardNavigation() {
    document.addEventListener('keydown', handleGlobalKeydown);
}

function handleGlobalKeydown(event) {
    const grid = document.getElementById('machineGrid');
    const cards = Array.from(grid.children);
    const currentIndex = cards.indexOf(document.activeElement);

    if (currentIndex === -1) return;

    const cols = 2;
    let newIndex = currentIndex;

    switch (event.key) {
        case 'ArrowUp': {
            newIndex = currentIndex - cols;
            if (newIndex < 0) newIndex = currentIndex;
            break;
        }
        case 'ArrowDown': {
            newIndex = currentIndex + cols;
            if (newIndex >= cards.length) newIndex = currentIndex;
            break;
        }
        case 'ArrowLeft': {
            newIndex = currentIndex - 1;
            if (newIndex < 0 || Math.floor(currentIndex / cols) !== Math.floor(newIndex / cols)) {
                newIndex = currentIndex;
            }
            break;
        }
        case 'ArrowRight': {
            newIndex = currentIndex + 1;
            if (newIndex >= cards.length || Math.floor(currentIndex / cols) !== Math.floor(newIndex / cols)) {
                newIndex = currentIndex;
            }
            break;
        }
        case 'Enter':
        case ' ': {
            event.preventDefault();
            const machine = machines[currentIndex];
            selectMachine(machine);
            return;
        }
        default:
            return;
    }

    if (newIndex !== currentIndex && newIndex >= 0 && newIndex < cards.length) {
        cards[newIndex].focus();
        event.preventDefault();
    }
}

function handleCardKeydown(event) {
    handleGlobalKeydown(event);
}

function selectMachine(machine) {
    updateBackgroundMedia(machine);

    channel.postMessage({
        type: 'MACHINE_SELECTED',
        data: { machineId: machine.id, machineName: machine.name }
    });
}

function notifyNewMachineRegistration(machine) {
    channel.postMessage({
        type: 'NEW_MACHINE_REGISTERED',
        data: machine
    });
}

function updateBackgroundMedia(machine) {
    const backgroundMedia = document.getElementById('backgroundMedia');

    if (machine.video) {
        backgroundMedia.style.backgroundImage = 'none';
        backgroundMedia.innerHTML = `<video autoplay loop muted playsinline style="width:100%;height:100%;object-fit:cover;"><source src="${machine.video}" type="video/mp4"></video>`;
    } else if (machine.image) {
        backgroundMedia.innerHTML = '';
        backgroundMedia.style.backgroundImage = `url('${machine.image}')`;
    } else {
        backgroundMedia.innerHTML = '';
        backgroundMedia.style.backgroundImage = 'none';
        backgroundMedia.classList.add('fallback');
    }
}

function updateMachineSelection(machineId) {
    const machine = machines.find(m => m.id === machineId);
    if (machine) {
        updateBackgroundMedia(machine);

        const cards = document.querySelectorAll('.machine-card');
        cards.forEach((card) => {
            if (Number.parseInt(card.dataset.machineId, 10) === machineId) {
                card.focus();
                currentFocusIndex = Number(card.dataset.index || 0);
            }
        });
    }
}

function updateBranchDisplay(branch) {
    document.getElementById('branchInfo').textContent = `Sucursal: ${branch}`;
}
