{% extends "layouts/mSecuriteTemplate.volt" %}

{% block page_title %}
<title>マイアカウント｜セキュリテ</title>
{% endblock %}

{% block page_meta %}
<?php
global $_MST_PAGE_META;
?>
<meta name="keywords" content="<?php echo $_MST_PAGE_META["keywords"]; ?>" />
<meta name="description" content="<?php echo $_MST_PAGE_META["description"]; ?>" />
{% endblock %}

{% block page_css %}
<link rel="stylesheet" type="text/css" href="/css/sp/mypage.css" media="screen,print" />
{% endblock %}

{% block page_header %}
{{ partial("partials/mheaderMypage") }}
{% endblock %}

{% block page_header_for_app %}
{{ partial("partials/mheaderMypageForApp") }}
{% endblock %}

{% block page_footer %}
{{ partial("partials/mfooter") }}
{% endblock %}


{% block page_contents %}
<?php
//本人確認未申請
if(!empty($member_info) && $member_info->identified_status==0 && $member_info->wait_for_identify == 0)
{
?>
<div class="border">
<h3>【重要】本人確認資料の提出のお願い</h3>
<p>ファンドを申込みされた方を対象に、本人確認資料（免許証等の氏名、現住所を確認可能な資料）をご提出いただいております。<br /> 
2回目以降、お手続きは必要ございません。</p>
<ul class="attention small">
<li>※本人確認の完了有無は、「<a href="/member/identity">本人確認</a>」からご確認いただけます。</li>
<li>※ファンドお申込み日より <strong class="red">7日以内</strong> に本人確認資料をご提出ください。</li>
</ul>
<p class="center"><a class="btn" href="/member/identity">本人確認資料、送付方法を見る</a></p>
</div>
<?php
}
?>


<h3><i></i> 出資・分配履歴</h3>

		<?php
		global $_MST_FUND_TAX_RATE;
 		$taxRate = $_MST_FUND_TAX_RATE;
 		
 		$totalInvestmentAfterShokan = 0;
 		$totalInvestmentBeforeShokan = 0;
 		$currentValueAfterShokan = 0;
 		$currentValueBeforeShokan = 0;
 		
 		foreach($paid_orders as $order)
		{
			$currentValuePair = calculateCurrentFundPrice($order);
			$currentValue = $currentValuePair[0];
			
			//$currentValue = $order->shokan_deposit;
			//$profit = $order->shokan_deposit - ($order->buy_kingk - $order->buy_fee);
			//$taxAmount = 0;
			//if($profit > 0)
			//{
			//	$profitWithtax = $profit / (1.00-$taxRate);
			//	$currentValue = floor($profitWithtax + ($order->buy_kingk - $order->buy_fee));
			//}
			
			//償還済ファンド
			if($order->fund_status == 5)
			{
				$currentValueAfterShokan  += $currentValue * $order->buy_suryo;
				$totalInvestmentAfterShokan += ($order->buy_kingk - $order->buy_fee);
 			}
 			else if($order->fund_status == 2 ||
 			       $order->fund_status == 3 ||
 			       $order->fund_status == 4 )
 			{
 				$currentValueBeforeShokan += $currentValue* $order->buy_suryo;
 				$totalInvestmentBeforeShokan += ($order->buy_kingk - $order->buy_fee);
 			}
		}
		
		$rimawariBeforeShokan = round( -100.00 + (100 * $currentValueBeforeShokan / $totalInvestmentBeforeShokan) , 2) . "%";
		$rimawariAfterShokan  = round( -100.00 + (100 * $currentValueAfterShokan / $totalInvestmentAfterShokan) , 2) . "%";
		$rimawariTotal  = round( -100.00 + (100 * ($currentValueBeforeShokan + $currentValueAfterShokan) / ($totalInvestmentBeforeShokan + $totalInvestmentAfterShokan)) , 2) . "%";
		
		?>
	
	


		<dl class="accordion">
		
			<dt class="red">償還前ファンド分</dt>
			<dd>
			<dl class="border">
				<dt>出資金額</dt>
				<dd class="right"><?php echo number_format($totalInvestmentBeforeShokan);?>円</dd>
				<dt>現時点の金額</dt>
				<dd class="right"><?php echo number_format($currentValueBeforeShokan);?>円</dd>
				<dt>利回り</dt>
				<dd class="right"><?php echo $rimawariBeforeShokan;?></dd>
			</dl>
			</dd>
		
			<dt class="blue">償還済ファンド分</dt>
			<dd>
			<dl class="border">
				<dt>出資金額</dt>
				<dd class="right"><?php echo number_format($totalInvestmentAfterShokan);?>円</dd>
				<dt>現時点の金額</dt>
				<dd class="right"><?php echo number_format($currentValueAfterShokan);?>円</dd>
				<dt>利回り</dt>
				<dd class="right"><?php echo $rimawariAfterShokan;?></dd>
			</dl>
			</dd>

			<dt>合計</dt>
			<dd>
				<dl class="border">
				<dt>出資金額</dt>
				<dd class="right"><?php echo number_format($totalInvestmentBeforeShokan + $totalInvestmentAfterShokan);?>円</dd>
				<dt>現時点の金額</dt>
				<dd class="right"><?php echo number_format($currentValueBeforeShokan + $currentValueAfterShokan);?>円</dd>
				<dt>利回り</dt>
				<dd class="right"><?php echo $rimawariTotal;?></dd>
				</dl>
			</dd>
		</dl>
<!--
		<p class="small inner">※会計期間開始後の合計金額です。受付中、会計期間前のファンドの金額は含まれていません。</p>
		<br />
-->


<h3><i></i> 未決済のファンド</h3>

	
		<dl class="accordion">
		<?php
		$unpaid_total = 0;
		foreach($unpaid_orders as $order)
		{
			$unpaidAmount = $order->buy_kingk - $order->paid_fkingk_cash - $order->buy_kingk_deposit;
			$unpaid_total += $unpaidAmount;
		?> 
		
		<dt><?php echo $order->fund_name;?></dt>
		<dd>
			<dl class="border">
				<dt>申込金額</dt>
				<dd class="right"><?php echo number_format($order->buy_kingk);?>円</dd>
					
				<dt>口数</dt>
				<dd class="right"><?php echo $order->buy_suryo;?>口</dd>
				
				<dt>申込日</dt>
				<dd><?php echo dateFormat($order->buy_date);?></dd>
					
				<dt>未入金額</dt>
				<dd class="right"><?php echo number_format($unpaidAmount);?>円</dd>
			
				
				<dd class="center">
				<?php 
				if($order->paid_type != 8) //クレジットカード払いの場合は表示しない
				{
					?>
					<a href="/fund/payment/dispatch?bid=<?php echo $order->buy_id;?>" class="btn orange">決済</a>
					<?php 
					if($order->fund_status == 2)
					{
					?>
					<a href="/mypage/fund/detail?bid=<?php echo $order->buy_id;?>" class="btn gray">変更</a>
					<?php 
					}
				}
				?>
				</dd>
			</dl>
		</dd>
		<?php
		}
		?>
		</dl>
		
		<h4 class="red right inner"><b>未入金金額合計：<?php echo number_format($unpaid_total);?> 円</b></h4>

			
		<br />
		
		<h3><i></i> 決済済みのファンド</h3>
		
		<dl class="accordion">
		<?php
		$fund_status_mst = array(
				1 => '受付予定',
				2 => '受付中',
				3 => '受付終了',
				4 => '運用中',
				5 => '償還済',
				6 => 'キャンセル',
				9 => 'キャンセル'
		);
 
 
 		//
 		global $_MST_FUND_TAX_RATE;
 		$taxRate = $_MST_FUND_TAX_RATE;
 		
 		foreach($paid_orders as $order)
		{
			$currentValuePair = calculateCurrentFundPrice($order);
			$currentValue = $currentValuePair[0];//getFundCurrentValue($order->buy_kingk,$order->buy_fee,$_MST_FUND_TAX_RATE,$order->shokan_deposit  );
			$rimawari     = $currentValuePair[1];//getRimawari($order->buy_kingk,$order->buy_fee,$_MST_FUND_TAX_RATE,$order->shokan_deposit );
			
// 			$currentValue = $order->shokan_deposit;
// 			$profit = $order->shokan_deposit - ($order->buy_kingk - $order->buy_fee);
// 			$taxAmount = 0;
// 			if($profit > 0)
// 			{
// 				$profitWithtax = $profit / (1.00-$taxRate);
// 				$currentValue = floor($profitWithtax + ($order->buy_kingk - $order->buy_fee));
// 			}
			
// 			//利回り
// 			if($order->shokan_deposit == 0 || $order->buy_kingk == 0)
// 			{
// 				$rimawari = "--";
// 			}
// 			else
// 			{
// 				$rimawari = round( -100.00 + (100 * $currentValue / ($order->buy_kingk - $order->buy_fee)) , 2) . "%";
// 			}
			
		?> 
		
		<dt><?php echo $order->fund_name;?></dt>
		<dd>
			<dl class="border">
			<dt>ステータス</dt>
			<dd class="right"><?php echo $fund_status_mst[$order->fund_status];?></dd>
			
			<dt>ご出資時の金額</dt>
			<dd class="right"><?php echo number_format($order->buy_kingk - $order->buy_fee );?>　円</dd>
			
			<dt>現時点の金額（税引前）</dt>
			<dd class="right"><?php echo number_format($currentValue * $order->buy_suryo);?> 円</dd>
			
			<dt>利回り</dt>
			<dd class="right">
			<?php
			if(in_array($order->fund_status, array(4,5))) //運用中、償還済
			{
				echo $rimawari."%";
			}
			else
			{
				echo "-";
			}
			?>
			</dd>
			</dl>
		</dd>
		<?php
		}
		?> 
		</dl>
		<br />
	
		<?php 
		if(sizeof($msmatch_orders) > 0)
		{
		?>
			<h3><i></i> 寄付一覧</h3>
			<dl class="accordion">
			<?php
			$mm_order_status_map = array(
				1 => "申込確認中",
				2 => "決済済",
				6 => "キャンセル",
				9 => "キャンセル"
			);
			foreach($msmatch_orders as $order)
			{
			?> 
			<dt><?php echo $order->fund_name; ?></dt>
			<dd>
				<dl class="border">
				<dt>ステータス</dt>
				<dd class="right"><?php echo $mm_order_status_map[$order->buy_status]; ?></dd>
				
				<dt>寄付金額</dt>
				<dd class="right"><?php echo number_format($order->buy_kingk); ?>円</dd>
				</dl>
			</dd>
			<?php
			}
			?> 
			</dl>
			<br />
			<?php
		}
		?> 
		
		
		<?php 
		if(sizeof($ec_orders) > 0)
		{
		?>
			<h3><i></i> 物販等一覧</h3>
			<dl class="accordion">	
			<?php
			$ec_order_status_map = array(
				1 => "申込確認中",
				2 => "決済済",
				6 => "キャンセル",
				9 => "キャンセル"
			);
			
			foreach($ec_orders as $order)
			{
			?> 
			<dt><?php echo $order->item_names; ?></dt>
			<dd>
				<dl class="border">
				<dt>ステータス</dt>
				<dd class="right"><?php echo $ec_order_status_map[$order->status];?></dd>
				
				<dt>金額</dt>
				<dd class="right"><?php echo number_format($order->order_total); ?>円</dd>
				</dl>
			</dd>
			<?php
			}
			?> 
			</dl>
			<br />
			<?php
		}
		?>
		
		
		
		<h3><i></i> クレジットカード</h3>
		<div class="inner">
			<h4>利用限度額</h4>
			<p class="right"><?php echo number_format($remain_card_kingk);?>円</p>
		</div>
		<dl class="accordion">	
		<?php
		foreach($card_orders as $order)
		{
		?> 
		<dt><?php echo $order->fund_name; ?></dt>
		<dd>
			<dl class="border">
				<dt>利用金額</dt>
				<dd class="right"><?php echo number_format($order->buy_kingk); ?>円</dd>
				
				<dt>利用日</dt>
				<dd class="right"><?php echo dateFormat($order->buy_date)?></dd>
				
				<dt>利用金額解放日</dt>
				<dd class="right"><?php echo date('Y年n月j日', strtotime($order->buy_date.' +2 month +1 day'))?></dd>
			</dl>
		</dd>
		<?php
		}
		?> 
		</dl>
		<br />



		<h3><i></i> 支払留保サービス<a href="/glossary" class="link"><i class="question"></i> 支払留保サービスとは？</a></h3>
		<div class="inner">
		<h4>償還・分配総額</h4>
		<p class="right"><?php echo number_format($depositShokan);?>円</p>
			
		<h4>支払留保金額</h4>
		<p class="right"><?php echo number_format($depositKakutei);?>円</p>
	
		<h4>支払手続中金額</h4>
		<p class="red right"><?php echo number_format($depositYoyaku);?>円</p>
	
		<h4>新規購入/出金指示可能金額※</h4>
		<p class="right"><?php echo number_format($depositUsable);?>円</p>
		
		<p class="small">※支払留保金額のうち、購入および出金指示が可能な金額です。</p>
		</div>

<div class="border center">
<p>支払留保金をご利用になる場合は、以下のボタンを押してください。</p>
<a href="/mypage/deposit" class="btn orange">分配金のご利用</a>
</div>
{% endblock %}