<?php
/**
 * UpdateContentTypeDraftSignal class
 *
 * @copyright Copyright (C) eZ Systems AS. All rights reserved.
 * @license For full copyright and license information view LICENSE file distributed with this source code.
 * @version 2014.11.1
 */

namespace eZ\Publish\Core\SignalSlot\Signal\ContentTypeService;

use eZ\Publish\Core\SignalSlot\Signal;

/**
 * UpdateContentTypeDraftSignal class
 * @package eZ\Publish\Core\SignalSlot\Signal\ContentTypeService
 */
class UpdateContentTypeDraftSignal extends Signal
{
    /**
     * ContentTypeDraftId
     *
     * @var mixed
     */
    public $contentTypeDraftId;
}
