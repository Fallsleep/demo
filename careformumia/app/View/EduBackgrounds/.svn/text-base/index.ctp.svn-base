<!-- File: /app/View/EduBackgrounds/index.ctp -->

<table>
    <tr>
        <th>陪月員編號</th>
        <th>證書頒發日期</th>
        <th>證書類別</th>
        <th>證書名稱</th>
        <th>備註</th>
        <th>相片</th>
        <th>建立日期</th>
        <th>建立人</th>
        <th>修改日期</th>
        <th>修改人</th>
        <!--th></th-->        
    </tr>

    <!-- Here is where we loop through our $edu_background array, printing out edu background info -->

    <?php 
	foreach ($edu_backgrounds as $edu_background): 
	?>
    <tr>
        <td><?php echo $edu_background['Worker']['worker_no']; ?></td>
        <td><?php echo $edu_background['EduBackground']['award_date']; ?></td>
        <td><?php echo $edu_background['EduBackground']['award_type']; ?></td>
        <td><?php echo $edu_background['EduBackground']['award_title']; ?></td>
        <td><?php echo $edu_background['EduBackground']['remark']; ?></td>
        <td><?php echo $edu_background['EduBackground']['img']; ?></td>
        <td><?php echo $edu_background['EduBackground']['created']; ?></td>
        <td><?php echo $edu_background['EduBackground']['created_by']; ?></td>
        <td><?php echo $edu_background['EduBackground']['modified']; ?></td>
        <td><?php echo $edu_background['EduBackground']['modified_by']; ?></td>
        <!--td>
            <?php // echo $this->Html->link('编辑', array('action' => 'edit', $edu_background['EduBackground']['id'])); ?>
        </td-->
    </tr>
    <?php endforeach; ?>
</table>