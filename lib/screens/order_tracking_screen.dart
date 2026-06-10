import 'package:flutter/material.dart';
import '../main_scaffold.dart';
import '../services/order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = [];
  Map<String, dynamic>? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _loading = true; _error = null; });
    final result = await OrderService.getMyOrders();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true) {
        _orders = result['data'] ?? [];
      } else {
        _error = result['message'] ?? 'Orders load nahi hue';
      }
    });
  }

  Future<void> _loadOrderDetail(int id) async {
    final result = await OrderService.getOrderById(id);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _selectedOrder = result['data']);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':  return Colors.green;
      case 'cancelled':  return Colors.red;
      case 'on_the_way': return Colors.blue;
      case 'preparing':  return Colors.orange;
      case 'confirmed':  return Colors.teal;
      default:           return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':    return 'Pending ⏳';
      case 'confirmed':  return 'Confirmed ✅';
      case 'preparing':  return 'Preparing 👨‍🍳';
      case 'on_the_way': return 'On the Way 🚴';
      case 'delivered':  return 'Delivered 🎉';
      case 'cancelled':  return 'Cancelled ❌';
      default:           return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue, foregroundColor: Colors.white,
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kBlue))
          : _error != null
          ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 14),
          Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadOrders, style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white),
              child: const Text('Retry')),
        ],
      ))
          : _orders.isEmpty
          ? const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📦', style: TextStyle(fontSize: 60)),
          SizedBox(height: 12),
          Text('Koi order nahi abhi tak', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ))
          : RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _orders.length,
          itemBuilder: (_, i) {
            final order = _orders[i];
            final status = order['status'] ?? 'pending';
            return GestureDetector(
              onTap: () async {
                await _loadOrderDetail(order['id'] as int);
                if (!mounted) return;
                if (_selectedOrder != null) {
                  _showOrderDetail(context, _selectedOrder!);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Row(children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: kLightBlue, borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(order['emoji'] ?? '🍽️',
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['recipe_name'] ?? 'Order',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text('Order #${order['id']}  •  Qty: ${order['quantity']}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text(order['payment_method']?.toUpperCase() ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel(status),
                          style: TextStyle(fontSize: 11, color: _statusColor(status),
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    final tracking = order['tracking'];
    final stages   = tracking?['stages'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Order #${order['id']} Tracking',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                // Recipe info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(children: [
                    Text(order['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(order['recipe_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Payment: ${(order['payment_method'] ?? '').toUpperCase()}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('Address: ${order['delivery_address'] ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 14),

                // Tracking timeline
                if (stages.isNotEmpty) ...[
                  const Align(alignment: Alignment.centerLeft,
                      child: Text('Order Progress',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(children: stages.asMap().entries.map((e) {
                      final idx   = e.key;
                      final stage = e.value as Map<String, dynamic>;
                      final done  = stage['completed'] == true;
                      final isLast = idx == stages.length - 1;
                      final stageLabel = _statusLabel(stage['stage'] as String);

                      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Column(children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: done ? kBlue : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(done ? Icons.check : Icons.circle_outlined,
                                color: done ? Colors.white : Colors.grey, size: 14),
                          ),
                          if (!isLast)
                            Container(width: 2, height: 30,
                                color: done ? kBlue : Colors.grey[200]),
                        ]),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(stageLabel,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: done ? Colors.black87 : Colors.grey,
                                  fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ]);
                    }).toList()),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
