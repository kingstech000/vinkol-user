/* All demo data. Amounts are in NGN minor-free units; the market layer converts and formats.
 * Nothing here is real, and no screen holds a literal currency symbol. */

/* AgentModel carries firstname/lastname, phone and imageUrl; ratings/rider-average gives the
 * score. There is no verified flag and no lifetime trip count. */
export const rider = {
  name: 'Emeka O.',
  initials: 'EO',
  rating: 4.9,
  vehicle: 'Honda CB · LSD 4471',
};

/* No ETA, no declared value, no protection premium — none of those exist in the payload. */
export const activeOrder = {
  ref: 'VK-8F2K-9130',
  status: 'with rider',
  pickup: { title: '14 Adeola Odeku Street', meta: 'Victoria Island · Picked up 10:24' },
  dropoff: { title: 'Ikeja City Mall', meta: 'Alausa' },
  distanceKm: 18.4,
  fee: 3200,
};

export const orders = [
  { ref: 'VK-8F2K-9130', from: 'Victoria Island', to: 'Ikeja City Mall', status: 'with rider', when: 'Today, 10:24', amount: 3200 },
  { ref: 'VK-7C1P-8842', from: 'Lekki Phase 1', to: 'Yaba', status: 'pending', when: 'Today, 09:58', amount: 2650 },
  { ref: 'VK-6B9M-7715', from: 'Surulere', to: 'Apapa', status: 'pending', when: 'Today, 08:40', amount: 4100 },
  { ref: 'VK-5A3L-6604', from: 'Ajah', to: 'Oniru', status: 'delivered', when: 'Yesterday', amount: 2900 },
  { ref: 'VK-4Z8K-5583', from: 'Maryland', to: 'Gbagada', status: 'delivered', when: 'Yesterday', amount: 1850 },
  { ref: 'VK-3Y7J-4472', from: 'Festac', to: 'Ikorodu', status: 'unattended', when: '12 Aug', amount: 5400 },
  { ref: 'VK-2X6H-3361', from: 'Ogba', to: 'Magodo', status: 'cancelled', when: '11 Aug', amount: 2200 },
  { ref: 'VK-1W5G-2250', from: 'Ikoyi', to: 'Ebute Metta', status: 'delivered', when: '10 Aug', amount: 3750 },
];

export const transactions = [
  { title: 'Delivery to Ikeja City Mall', ref: 'VK-8F2K-9130', when: 'Today, 10:24', amount: -3200, kind: 'out' },
  { title: 'Wallet top-up', ref: 'Card ending 4471', when: 'Today, 09:12', amount: 50000, kind: 'in' },
  { title: 'Delivery to Oniru', ref: 'VK-5A3L-6604', when: 'Yesterday', amount: -2900, kind: 'out' },
  { title: 'Refund · VK-3Y7J-4472', ref: 'Unattended order', when: '12 Aug', amount: 5400, kind: 'in' },
  { title: 'Delivery to Gbagada', ref: 'VK-4Z8K-5583', when: '11 Aug', amount: -1850, kind: 'out' },
];

export const savedPlaces = [
  { icon: 'home', title: 'Home', meta: '22 Bourdillon Road, Ikoyi' },
  { icon: 'store', title: 'Work', meta: 'Vinkol HQ, Victoria Island' },
  { icon: 'clock', title: 'Ikeja City Mall', meta: 'Obafemi Awolowo Way, Alausa' },
];

export const vehicles = [
  { id: 'bike', label: 'Bike', meta: 'Up to 10 kg · fastest', eta: '25–35 min', price: 3200, selected: true },
  { id: 'car', label: 'Car', meta: 'Up to 60 kg · fragile-safe', eta: '30–45 min', price: 5800 },
  { id: 'van', label: 'Van', meta: 'Up to 500 kg · bulk', eta: '45–70 min', price: 14500 },
];

export const walletBalance = 128400;
