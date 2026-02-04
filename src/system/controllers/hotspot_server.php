<?php
_admin();
$ui->assign('_system_menu', 'services');

$action = $routes['1'];
$ui->assign('_admin', $admin);

if (!in_array($admin['user_type'], ['SuperAdmin', 'Admin'])) {
    _alert(Lang::T('You do not have permission to access this page'), 'danger', "dashboard");
}

switch ($action) {
    case 'add':
        $routers = ORM::for_table('tbl_routers')->find_many();
        $ui->assign('routers', $routers);
        $ui->display('admin/hotspot/server_add.tpl');
        break;

    case 'add-post':
        $router_name = _post('router');
        $server_name = _post('server_name');
        $interface = _post('interface');
        $pool_name = _post('pool_name');
        $pool_ranges = _post('pool_ranges');
        $hotspot_address = _post('hotspot_address');
        $dns_name = _post('dns_name');

        $router = ORM::for_table('tbl_routers')->where('name', $router_name)->find_one();

        $server = [
            'server_name' => $server_name,
            'interface' => $interface,
            'pool_name' => $pool_name,
            'pool_ranges' => $pool_ranges,
            'hotspot_address' => $hotspot_address,
            'dns_name' => $dns_name
        ];

        require_once $DEVICE_PATH . DIRECTORY_SEPARATOR . "MikrotikHotspot.php";
        $hotspot = new MikrotikHotspot();
        $hotspot->add_hotspot_server($router, $server);

        r2(getUrl('services/hotspot'), 's', 'Hotspot server created successfully');
        break;

    default:
        $ui->display('admin/404.tpl');
}
